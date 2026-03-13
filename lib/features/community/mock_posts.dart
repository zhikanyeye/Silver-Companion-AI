enum CommunityFeedBucket { recommended, latest }

class CommunityPost {
  const CommunityPost({
    required this.username,
    required this.identity,
    required this.tag,
    required this.title,
    required this.location,
    required this.time,
    required this.summary,
    required this.responseStatus,
    required this.bucket,
  });

  final String username;
  final String identity;
  final String tag;
  final String title;
  final String location;
  final String time;
  final String summary;
  final String responseStatus;
  final CommunityFeedBucket bucket;
}

const List<CommunityPost> mockPosts = [
  CommunityPost(
    username: '王阿姨',
    identity: '3号楼住户',
    tag: '求助',
    title: '3号楼灯泡更换求助',
    location: '朝阳区',
    time: '10分钟前',
    summary: '家里灯泡坏了，希望有邻居方便时帮忙看一下。',
    responseStatus: '等待帮助中',
    bucket: CommunityFeedBucket.recommended,
  ),
  CommunityPost(
    username: '李叔叔',
    identity: '社区志愿者',
    tag: '互助',
    title: '代取药顺路互助',
    location: '望京街道',
    time: '35分钟前',
    summary: '下午去社区卫生服务中心取药，可顺路帮邻居代领常用药。',
    responseStatus: '已有2人响应',
    bucket: CommunityFeedBucket.latest,
  ),
];
