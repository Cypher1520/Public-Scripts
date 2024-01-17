<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#---AutoReply
    #$reply = "<html><head></head><body><p>first line</br>second line</p></body></html>"

    $reply = 
    "<html>
    <head></head>
    <body>
        <p>
            Thank you for your email.</br>
            </br>
            Please note Reena Sharma is no longer with Travel Alberta. For all People & Performance/HR related inquiries please contact Laura Lyons, Manager, People & Performance at laura.lyons@travelalberta.com or 403-648-1027.</br>`
            </br>
            Thank you,</br>
            Travel Alberta People & Performance Team
        </p>
    </body>
    </html>"
    Set-MailboxAutoReplyConfiguration "MAILBOX" -AutoReplyState Enabled -InternalMessage $reply -ExternalMessage $reply