class EmailRequest{
   late String to;
   late String subject;
   late String mail;
   late String from;

   EmailRequest(this.to, this.subject, this.mail, this.from);
   Map<String, dynamic> toJson() {
      return {
         'to': to,
         'subject': subject,
         'mail':mail,
         'from':from
      };
   }
}