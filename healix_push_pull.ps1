<#

Name      : Healix Integration

Version   : 2.0

Developer : CIS - Automation Factory

Features  : push the ticket data to healix and fetch the alert creation result

Description : This will push the data to healix and fetch the result of the alert creation

#>



param(
[parameter(Mandatory=$True,Position=0)][string]
 $inc_host,
[parameter(Mandatory=$True,Position=1)][string]
$short_Desc,
[parameter(Mandatory=$True,Position=2)][string]
$id
)
try{
#Healix -Data
$Account_ID = "205"
$Apikey = "8D5A6AE6A37AC13"
$healix_Url = "http://10.181.11.53:8080/api/Agent/PushAlert/"

#functon to push data to Healix
            
                $head = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                $head.Add('apikey',$Apikey)
                $head.Add('Accept','application/json')
                $head.Add('Content-Type','application/json')

                $healix_Body = "{
                                  ""AccountId"": ""$Account_ID"",
                                  ""HostName"": ""$inc_host"",
                                  ""AlertDescription"": ""$short_Desc"",
                                  ""ITSMTicketId"": ""$id"",
                                  ""ManualParameterIdentificationRequired"": ""False""
                                }"

                $short_Desc

                $Res = Invoke-RestMethod -Method 'Post' -Uri $healix_Url -Body $healix_Body -Headers $head

                #$Res.IsFailure
                #$Res.Msg
                if($Res.IsFailure -like "*True*"){
                    
                    return $Res.Msg
                }
                if($Res.IsFailure -like "*False*"){
                    
                    return "successfull"
                }
}
            
            catch{
                $_
            
            }
        
        
