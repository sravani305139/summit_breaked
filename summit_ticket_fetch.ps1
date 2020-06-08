<#

Name      : SymphonySummit Integration

Version   : 2.0

Developer : CIS - Automation Factory

Features  : read ticket data from symphony summit and push the ticket to healix

Description : This will read the details from symphony summit.

#>

#Summit - Data
$user = "hoautomation@gtaa.com"
$pass = "Welcome@123"
$org_ID = "1"
$Instance = "IT"
$State = "Open"
$work_group = "SERVICE DESK"#"INF-MONITORING"
$servicename = "IM_GetIncidentList"
$summit_uri = "https://itservicedeskportaldev.ppcgtaa.com/API/REST/Summit_RESTWCF.svc/RestService/CommonWS_JsonObjCall"

$proxy = "{'ReturnType': 'JSON','Password': '$pass' ,'UserName': '$user'}"
$filter = "{'OrgID': '$org_ID' ,'Instance': '$Instance' ,'Status': '$State','WorkgroupName': '$work_group'}"
$commom_parm ="{'_ProxyDetails': $proxy ,'objIncidentCommonFilter': $filter}"


try{

        #Rest API call to summit
        function rest_Api_call{
        [cmdletbinding()]
            param(
                $body_data,$action
            )

            try{
                Write-Host "in restcall"
                $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))
                # Set proper headers
                $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
                $headers.Add('Accept','application/json')
                $headers.Add('Content-Type','application/json')
                $method = "post"                
                $data = $body_data.Replace("'",'"')
                #Write-Host $data
                $response = Invoke-WebRequest -Headers $headers -Method $method -Uri $summit_uri -Body $data
                #Write-Host $response
                
                $res_val = $response.RawContent.Split("`n")[-1] | ConvertFrom-Json
                if($action -like "*update*"){
                    return $res_val
                }
                else{
                    return $res_val.OutputObject
                    }
            }
            catch{
                 $_
                 return "API is NotReachable"
            }
 }
        
        #fetch all the data from a work group
        $body = "{
                    ""ServiceName"": ""$servicename"",
                    ""objCommonParameters"": $commom_parm
                 }"
        #summit rest call
        $read_output = rest_Api_call -body_data $body
        if ($read_output -notlike "*NotReachable*"){
            $Inc_ID = "Incident ID" 
            $config_item = "IT_Event Details_Configuration Item"
            $ticket_dump = $read_output.MyTickets
    
            foreach($ticket in $ticket_dump){
                $id = $ticket.$Inc_ID
                $inc_host = $ticket.$config_item
                ###################
                #fetch Short description
                $inc_body = "{ 
                               ""ServiceName"":""IM_GetIncidentDetailsAndChangeHistory"",
                               ""objCommonParameters"":
                                   { 
                                        '_ProxyDetails':$proxy,
                                        'TicketNo':$id
                                    } 
                              } "
                #summit rest call
                $sub_data = rest_Api_call -body_data $inc_body
                if ($sub_data -notlike "*NotReachable*"){
                    $complete_Data = $sub_data.IncidentDetails.TicketDetails
                    #Write-Host $complete_Data 
                    $short_Desc = $complete_Data.Subject
                    Write-Host "inc_host"$inc_host 
                    Write-Host "short_Desc"$short_Desc 
                    Write-Host "id"$id
            }
        }
}
}
catch{
    $_
}