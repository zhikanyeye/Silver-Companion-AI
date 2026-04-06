function jsonResponse(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

export async function onRequest(context) {
  const method = context.request.method;
  const key = context.params.key;
  
  if (!key) {
    return jsonResponse({error: 'Key is required'}, 400);
  }

  // Ensure SILVER_KV namespace is bound in Cloudflare Pages dashboard
  if (!context.env.SILVER_KV) {
    return jsonResponse({error: 'KV namespace SILVER_KV is not bound'}, 500);
  }

  try {
    if (method === 'GET') {
      const data = await context.env.SILVER_KV.get(key, { type: 'text' });
      if (data === null) {
        return jsonResponse({error: 'Not found', data: null}, 404);
      }
      return new Response(data, {
        headers: {'content-type': 'application/json; charset=utf-8'},
      });
    }
    
    if (method === 'PUT' || method === 'POST') {
      const body = await context.request.text();
      
      // Validate JSON format roughly
      try {
        JSON.parse(body);
      } catch (e) {
        return jsonResponse({error: 'Invalid JSON body'}, 400);
      }

      await context.env.SILVER_KV.put(key, body);
      return jsonResponse({success: true}, 200);
    }
    
    if (method === 'DELETE') {
      await context.env.SILVER_KV.delete(key);
      return jsonResponse({success: true}, 200);
    }
    
    return jsonResponse({error: 'Method not allowed'}, 405);
  } catch (error) {
    return jsonResponse({error: error.message}, 500);
  }
}
