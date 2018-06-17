# A powershell script for rebooting my NETGEAR WNDR4300v2
# This may work on other NETGEAR models.

# Router login credentials
$user = 'admin'
$pass = 'password'

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($user):$($pass)"))
$basicAuthValue = "Basic $encodedCreds"
$body = @{ submit_flag = "reboot"; yes = "Yes" }

$Headers = @{
    Authorization = $basicAuthValue
}

# You have to make this initial unauthenticated request to get the auth cookie.
$init = Invoke-WebRequest -Uri 'http://192.168.1.1/' -SessionVariable session

# The reboot page contains a timestamp value that's need for the reboot request, it can't be randomly
# generated.
$reboot = Invoke-WebRequest -Uri 'http://192.168.1.1/reboot.htm' -Headers $Headers -WebSession $session

# Extract the timestamp and issue the reboot command.
$found = $reboot.Content -match 'timestamp=(\d+)"'
if ($found) {
    $timestamp = $matches[1]
    $rebootReponse = Invoke-WebRequest -Uri "http://192.168.1.1/apply.cgi?/reboot_waiting.htm timestamp=$timestamp" -Headers $Headers -Method POST -Body $body -WebSession $session
    echo $rebootReponse.Content
}