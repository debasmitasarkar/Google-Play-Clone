class ChatInfoModel {
  final String text;
  final String userName;
  final String senderEmail;
  final String recieverSenderEmail;
  final String userImageUrl;
  final String imageUrl;
  final DateTime timestamp;
  final String transactionAmt;
  final String transactionDesc;

  ChatInfoModel(
      {this.text,
      this.userName,
      this.senderEmail,
      this.recieverSenderEmail,
      this.userImageUrl,
      this.imageUrl,
      this.timestamp,
      this.transactionAmt,
      this.transactionDesc});
}
