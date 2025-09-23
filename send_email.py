#!/usr/bin/env python3
import smtplib

from email.mime.text import MIMEText

gmail_user = 'gimpysticks@gmail.com'  
gmail_password ='udcfljpnnxctzimp' 

subject = '2nd Test message for gimpy'  
body = "Hey, what's up?\n\n- You crazy assed Gimp"

email_text = """\  
From: %s  
To: %s  
Subject: %s

%s
""" % (gmail_user, gmail_user, subject, body)

msg = MIMEText(email_text)

msg['From'] = gmail_user  
msg['To'] = gmail_user   
msg['Subject'] = subject 


try:  
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    server.ehlo()
    server.login(gmail_user, gmail_password)
    server.sendmail(gmail_user, gmail_user, msg.as_string())
    server.close()

    print ('Email sent!')
except:  
    print('Something went wrong...') 
