$nameSpaceName="root\cimv2\mdm\dmmap"
$className="MDM_AssignedAccess"
$obj = Get-CimInstance -Namespace $namespaceName -ClassName $className
Add-Type -AssemblyName System.Web
$obj.Configuration = [System.Web.HttpUtility]::HtmlEncode(@"

<?xml version="1.0" encoding="utf-8" ?>
<AssignedAccessConfiguration  
  xmlns="http://schemas.microsoft.com/AssignedAccess/2017/config" 
xmlns:win11="http://schemas.microsoft.com/AssignedAccess/2022/config"
 xmlns:v2="http://schemas.microsoft.com/AssignedAccess/201810/config"
>
  <Profiles>
    <Profile Id="{9A2A490F-10F6-4764-974A-43B19E722C23}">       
      <AllAppsList>
        <AllowedApps> 
          <App AppUserModelId="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" />
	  <App AppUserModelId="Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" />
        </AllowedApps> 
      </AllAppsList> 
          <v2:FileExplorerNamespaceRestrictions>
            <v2:AllowedNamespace Name="Downloads"/>
          </v2:FileExplorerNamespaceRestrictions>
      <win11:StartPins>
        <![CDATA[  
          { "pinnedList":[
	    {"packagedAppId":"windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"},
	    {"packagedAppId":"Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"}
          ] }
        ]]>
      </win11:StartPins>
      <Taskbar ShowTaskbar="true"/>
    </Profile> 
  </Profiles>
  <Configs>
    <Config>
    <AutoLogonAccount/>
      <DefaultProfile Id="{9A2A490F-10F6-4764-974A-43B19E722C23}"/>
    </Config>
  </Configs>
</AssignedAccessConfiguration>
    
"@)

Set-CimInstance -CimInstance $obj