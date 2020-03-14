<#
    TITLE.
        "Password-Expiry-Script.ps1"

    PURPOSE.
        Checks all users in the  Active Directory domain against the defined password policy, alerting users via email if their passwords will expire within 7 days.

    NOTES.
        The SMTP variable has been declared, so feel free to fill it in with the specifics of your environment.
        Will also log to a file of your choice, and send an automated email to the Help Desk email address in order to notify them daily of users whose passwords are expiring.
        Once the script has run, it will add a "final" daily log entry to show cutoffs.

    LOG.
            10/04/17 - Script finished (sk)

            12/19/17 - Script updated (apl)
            - Added HTML body with specific directions for all three account types (normal, RDP, and Service)
            - Added visuals to assist in describing process
            - Password complexity matrix

            12/29/2017
            - Adding logging to file found in $Path
            - Added Daily Summary email

            01/10/2018
            - Added Try/Catch exception handling
            - Cleaned up comments
            - Re-organized global variables; all at  the beginning of the script
            - Resolved issue with duplicate email notifications being sent

            02/08/2018
            - $PasswordPolicy variable was modified; still using AD-GetFineGrainedPasswordPolicy, but specifically pulling the one named "Service Accounts".
            - This modification was necessary because the "standard password policy" is no longer defined in AD.
            - Standard Password Policy is being defined in Default Domain Policy, which the previously used command does not pickup.
            - Added additional logging. Now, every entry for Service Accounts that are notified also includes the $ManagerEmailAddress.
            - This means we will know the email address that is being used for notifications.
            - Added $timestamp variable to be used in logging.
#>

#Error handling.
Try {

# Starting transcript to log script output
Start-Transcript -Path "\\path\to\transcript.file" -Append

# Variables
$smtpServer="smtp.company.com"
$expirein = "7"
$from = "Help Desk <helpdesk@companyc.com>"
$to = "helpdesk-alerts@company.com"
$Debug_Email = "person@company.com"
$timestamp = Get-Date -Format g
$date = Get-Date -format ddMMyyyy
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
$Path = "\\path\to\log.file"
$Debug_Path = "\\path\to\debug_log.file"
$OU_Exclude = @(
    'OU.company.local\To\Exclude'
    )
$NotificationSubject = "Password Expiry: Daily Summary"
$NotificationBody = "Attached is the log of users whose passwords will expire shortly.
`n
Please note that each user mentioned has been notified via email, with detailed instructions.
`n
This email was automatically generated. If you notice any errors, please contact HelpDesk@Company.com or call (555) 555-5555."
$NotificationAttachment = "\\path\to\log.file"
$Attachment = "\\path\to\attachment.file"


#GRABBING AD USERS WITH PROPERTIES : NAME, PASSOWRDNEVEREXPIRES, PASSWORDEXPIRED, PASSWORDLASTSET, EMAILADDRESS, SAMACCOUNTNAME(userid.. ie 'skim')

$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress, samaccountname | where {$PSITEM.Enabled -eq "True"} | where { $PSITEM.PasswordNeverExpires -eq $false } | where { $PSITEM.passwordexpired -eq $false } | where {$_.DistinguishedName -notlike '*service*' -and $_.DistinguishedName -notlike '*Accounts*'} | where {$OU_Exclude -notcontains $_.OrganizationalUnit}

#GRABBING EACH USER AND GETTING THE PASSWORD EXPIRATION TIMES

foreach ($user in $users)
{
    $Name = $user.samaccountname
    $userfullname =$user.name
    $emailaddress = $user.emailaddress #GRABS EMAIL ADDRESS OF EACH USER OR CHANGE THIS TO CORPSUPPORT@SCHONFELD.COM TO ONLY SEND MESSAGE TO US.
    $lastpasswordSetDate = $user.PasswordLastSet #GRABS PASSWORDLASTSET DATE OF EACH USER
    $PasswordPolicy = (Get-ADDefaultDomainPasswordPolicy) #GRABS THE PASSOWRDPOLICY FOR OUR DOMAIN (total of 4 policies, this one is for standard password policy
    $sent = "" # Reset in EMAIL SECTION

    #Write-Output to determine if their are logic or loop errors
    #Write-Output $user

    if ($emailaddress -eq $null)
    {
        $emailaddress = "HelpDesk@company.com"
    }


    #FINE GRAINED PASSWORD POLICY CHECK
    if (($PasswordPolicy) -ne $null)
    {
        $maxPasswordAge = ($passwordpolicy).maxpasswordage #GRABS THE MAXPASSWORDAGE OF OUR POLICY IN DAYS
    }

    $expireson = $lastpasswordsetdate + $maxPasswordAge  #ADDS PASSWORD SET DATE OF EACH USER TO THE MAXPASSWORDAGE WHICH DAY NUMBER TILL EXPIRE
    $today = (get-date)
    $daystillexpire = (New-TimeSpan -Start $today -End $Expireson).days #DISPLAYS THE DAYS TO EXPIRE BY CALCULATING THE EXPIRE TIME FROM TODAY'S DATE

    # Ruleset to determine if user will receive password expiry email

    $days = $daystillexpire

    if (($days) -gt "1")
    {
       $days =  "in " + "$daystillexpire" + " days."
    }
    else
    {
        $days = "today."
    }

$Smtp_Body = "Enter SMTP body here"

    # Email subject, including username

    $subject= $userfullname + " your password will expire $days"

    # EMAIL

    if (($daystillexpire -ge "0") -and ($daystillexpire -lt $expirein))
    {
        $sent = "Yes"

        $Debug_Body = $userfullname + " password will expire in $days. Timestamp - $timestamp."

        # SEND EMAIL MESSAGE
        Send-MailMessage -to $emailaddress -From $from -SmtpServer $smtpServer -Subject $Subject -BodyAsHtml $Smtp_Body -Attachments $Attachment

        # This will append to the log for each user who received a password expiry notification
        Add-Content -Path $Path -Value "`n Password will expire in $daystillexpire days - $userfullname ($timestamp)."

    }

    else #PASSWORD NOT EXPIRING LOG
    {
        $sent = "No"

      #END LOG FILE

    }

} # End User Processing

# Adding end of log entry
Add-Content -Path $Path -Value "`n End log entry for $today."

# Sending summary email
Send-MailMessage -To $to -From $from -Subject $NotificationSubject -Body $NotificationBody -SmtpServer $smtpServer -BodyAsHtml -Attachments $NotificationAttachment

# Stopping transcript
Stop-Transcript

#End of error handling.
}
Catch {
 $_.Exception
 exit 23206
}

# End
