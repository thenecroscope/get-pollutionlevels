Clear-Host
#Getting worklocation and change replace path seperates to help if running on Linux
$workingDirTemp = $PSCommandPath | Split-Path -Parent
$workingDir = $workingDirTemp -replace ("\\", "/") #for linux
$config = Import-Csv $($workingDir + "/configs/" + "config.csv")

function Get-FullStationDetails ($stations)
{
    $fullStationDetailsArray = @()

    foreach ($station in $stations)
    {
      #$debugIt = "https://api.aerisapi.com/airquality/$($station.stationid)?client_id=$($config.ClientID)&client_secret=$($config.ClientSecret)"
      try{
        $stationFullResponse = Invoke-RestMethod "https://api.aerisapi.com/airquality/$($station.stationid)?client_id=$($config.ClientID)&client_secret=$($config.ClientSecret)"
      }
      catch
      {

      }
            foreach ($stationDetails in $stationFullResponse)
            {

                foreach ($reading in $stationDetails.response.periods.pollutants)
                {
                    $stationDetailsObj = New-Object -TypeName PSCustomObject
                    $stationDetailsObj | Add-Member -NotePropertyName StationName -NotePropertyValue $stationDetails.response.place.name -Force
                    $stationDetailsObj | Add-Member -NotePropertyName StationID -NotePropertyValue $stationDetails.response.id -Force
                    $stationDetailsObj | Add-Member -NotePropertyName Name -NotePropertyValue $reading.name -Force
                    $stationDetailsObj | Add-Member -NotePropertyName ValuePPB -NotePropertyValue $reading.valuePPB -Force
                    $stationDetailsObj | Add-Member -NotePropertyName ValueUGM3 -NotePropertyValue $reading.valueUGM3 -Force
                    $stationDetailsObj | Add-Member -NotePropertyName AQI -NotePropertyValue $reading.aqi -Force
                    $stationDetailsObj | Add-Member -NotePropertyName Category -NotePropertyValue $reading.category -Force
                    $stationDetailsObj | Add-Member -NotePropertyName Colour -NotePropertyValue $reading.color -Force
                    $fullStationDetailsArray += $stationDetailsObj 
                }
                }
            
            }
            return $fullStationDetailsArray
    }

function Get-Stations ($StationDetails)
{
    $stationArray = @()

    foreach ($station in $StationDetails.Response)
    {
        $stationObj = New-Object -TypeName PSObject -Property @{
            StationID          = $station.id
            Place              = $station.place.name
            DistanceMi         = $station.relativeTo.DistanceMi
        }

     $stationArray += $stationObj 
    }
    return $stationArray
}


b 
try {
    [PSCustomObject[]]$fullResponse = Invoke-RestMethod "https://api.aerisapi.com/airquality/closest?p=$($config.Town),$($config.Country)&limit=5&client_id=$($config.ClientID)&client_secret=$($config.ClientSecret)"
            if ($fullresponse.count -ge 1){
                Write-Host $($ip.IPTOCHECK) "Details Found:" -ForegroundColor Red
                $stations = Get-Stations $fullResponse
                $stationDetails =  Get-FullStationDetails $stations
            }
            else
            {
                Write-Host $($ip.IPTOCHECK) "Unable to find any details" -ForegroundColor Green
            }
}
catch {
    $_.Exception.Response 
    Write-Host "Error!" -ForegroundColor Red            
}
