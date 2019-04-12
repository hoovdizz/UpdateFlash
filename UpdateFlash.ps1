#Created to check and download latest Flash
#Checks Live Version vs what is deployed, then downloads and email notification if newer version is found
#Creation date : 4-2-2019
#Creator: Alix N Hoover



#Variables to your software Share
$SCCMSource = '\\sccm\software\Adobe\Flash'

#Variables-Mail
$MailServer = "MAIL"
$recip = "TO"
$sender = "FROM"
$subject = "Flash Update"
#where you put your schedule task
$ServerName = "SCCM" 
#where you put your documentation on deploying files
$doc='onenote:///L:\Documentation\--------D2408C04CB35}&page-id={C876A107-9DA6-4D7D-92DF-197E45DEB7EE}&object-id={3A6DC248-3FA0-4F1D-AB55-42C4E7D96436}&A6'



#weblinks
$flashURL = (curl -Uri https://get.adobe.com/de/flashplayer/about/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)

#Check Current Version

$flashURL = (curl -Uri https://get.adobe.com/de/flashplayer/about/ -UseBasicParsing | Select-Object Content -ExpandProperty Content)
$flashURL -match "<td>Internet Explorer – ActiveX</td>            `n`t`t`t`n            `t<td>(?<content>.*)</td>"    
$flashFullVersion = $matches['content']  
$flashMajorVersion = $flashFullVersion.Substring(0,2)    

$flashURLPrefix = "https://fpdownload.macromedia.com/pub/flashplayer/pdc/" + $FlashFullVersion
$flashURLPPAPI = $FlashURLPrefix + "/install_flash_player_" + $FlashMajorVersion + "_ppapi.msi" 
$flashURLNPAPI = $FlashURLPRefix +  "/install_flash_player_" + $FlashMajorVersion + "_plugin.msi"
$flashURLActiveX = $FlashURLPRefix + "/install_flash_player_" + $FlashMajorVersion + "_active_x.msi"    



$versioncheck = $flashFullVersion
$checkfolder = "$SCCMSource\$versioncheck"


#Get Links
$outfilePPAPI = "install_flash_player_" + $FlashMajorVersion + "_ppapi.msi"
$outfileNPAPI = "install_flash_player_" + $FlashMajorVersion + "_plugin.msi"
$outfileActiveX = "install_flash_player_" + $FlashMajorVersion + "_active_x.msi" 


IF (!(test-path $checkfolder)) {
    Write-Output "$checkfolder does not exist"
   
   $destinationfolder = "$checkfolder"
    Write-Output "Creating $destinationfolder"
    [System.IO.Directory]::CreateDirectory($destinationfolder)
  

$outfilePPAPI = "$destinationfolder\$outfilePPAPI"
$outfileNPAPI = "$destinationfolder\$outfileNPAPI"
$outfileActiveX = "$destinationfolder\$outfileActiveX"
   
   
   
   
# Download Flash from the web
Write-Output "Downloading $outfilePPAPI"
Invoke-WebRequest -Uri $flashURLPPAPI -OutFile $outfilePPAPI -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::explorer
Write-Output "Downloading $outfileNPAPI"
Invoke-WebRequest -Uri $flashURLNPAPI -OutFile $outfileNPAPI -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::explorer
Write-Output "Downloading $outfileActiveX"
Invoke-WebRequest -Uri $flashURLActiveX -OutFile $outfileActiveX -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::explorer

  
    
#sendemail
Write-Output "Downloads Completed, Sending Email"

$body ="<html></body> <BR> Flash Version <p style='color:#FF0000'>  $versioncheck </p> is ready for deployment Via SCCM  <BR>"

$body+= "<a href=$doc>Here are Directions</a> "
$body+="<BR> this is a Scheduled task on $ServerName"
 
Send-MailMessage -From $sender -To $recip -Subject $subject -Body ( $Body | out-string ) -BodyAsHtml -SmtpServer $MailServer
}

    ELSE { Write-Output "$checkfolder already exists"}