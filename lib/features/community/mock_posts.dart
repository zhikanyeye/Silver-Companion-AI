class CommunityPost {
  const CommunityPost({
    required this.username,
    required this.tag,
    required this.location,
    required this.time,
    required this.content,
  });

  final String username;
  final String tag;
  final String location;
  final String time;
  final String content;
}

const List<CommunityPost> mockPosts = [
  CommunityPost(
    username: '王阿姨',
    tag: '求助',
    location: '朝阳区',
    time: '10分钟前',
    content: '家里灯泡坏了，谁能帮忙换一下？我在3号楼。',
  ),
  CommunityPost(
    username: '李叔叔',
    tag: '互助',
    location: '望京街道',
    time: '35分钟前',
    content: '我可以帮大家代取药，下午四点前都在小区。',
  ),
];
