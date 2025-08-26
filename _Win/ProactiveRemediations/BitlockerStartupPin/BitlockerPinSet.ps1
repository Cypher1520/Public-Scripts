<#
    =========
    Written by Chris Rockwell
    chris.rockwell@insight.com
    =========
    #Description
    Prompts user to input startup key with confirmation, if they don't match performs a loop until they do
    =========
    Version 1.0
    10/18/2022 - Original Script
#>
function Textbox1 {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Bitlocker Startup Pin (C:)'
    $form.Size = New-Object System.Drawing.Size(300, 200)
    $form.MaximizeBox = $False
    $form.MinimizeBox = $False
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75, 120)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150, 120)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = 'Set Bitlocker Startup PIN:'
    $form.Controls.Add($label)

    $textBoxNew = New-Object System.Windows.Forms.TextBox
    $textBoxNew.Location = New-Object System.Drawing.Point(10, 40)
    $textBoxNew.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBoxNew)

    $textBoxConfirm = New-Object System.Windows.Forms.TextBox
    $textBoxConfirm.Location = New-Object System.Drawing.Point(60, 40)
    $textBoxConfirm.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBoxConfirm)

    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $x = $textBox.Text
        $x
    }
}

function Textbox2 {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Bitlocker Startup Key'
    $form.Size = New-Object System.Drawing.Size(300, 200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75, 120)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150, 120)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = 'Confirm Key:'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBox)

    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $x = $textBox.Text
        $x
    }
}

function NoMatch {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Error!'
    $form.Size = New-Object System.Drawing.Size(215, 125)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(65, 50)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    <#
    $cancelButton3 = New-Object System.Windows.Forms.Button
    $cancelButton3.Location = New-Object System.Drawing.Point(150, 120)
    $cancelButton3.Size = New-Object System.Drawing.Size(75, 23)
    $cancelButton3.Text = 'Cancel'
    $cancelButton3.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form3.CancelButton = $cancelButton2
    $form3.Controls.Add($cancelButton3)
    #>

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = 'Keys did not match please try again'
    $form.Controls.Add($label)

    <#
    $textBox2 = New-Object System.Windows.Forms.TextBox
    $textBox2.Location = New-Object System.Drawing.Point(10, 40)
    $textBox2.Size = New-Object System.Drawing.Size(260, 20)
    $form2.Controls.Add($textBox2)
    #>

    $form.Topmost = $true

    #$form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()
}

#Startup Key entry/confirmation
$input1 = Textbox1
$input2 = Textbox2

if (-not($input1 -eq $input2)) {
    do {
        NoMatch
        $input1 = Textbox1
        $input2 = Textbox2
    } until ($input1 -eq $input2)
}

#=========Script Body
#Set the bitlocker startup key

$bitlockerkey = (Get-BitLockerVolume -MountPoint C).KeyProtector | where { $_.KeyProtectorType -eq "TpmAndinAndStartupKeyProtectorP" -or $_.KeyProtectorType -eq "TpmAndPinProtector" }
if (-not($bitlockerkey -eq $null)) {
    exit 0
}
else {
    $SecureString = ConvertTo-SecureString $input2 -AsPlainText -Force
    Add-BitLockerKeyProtector -MountPoint "C:" -Pin $SecureString -TPMandPinProtector
}
    
#Create Tag file for detection
if (-not (Test-Path "$($env:ProgramData)\AutopilotConfig")) {
    Mkdir "$($env:ProgramData)\AutopilotConfig"
}
Set-Content -Path "$($env:ProgramData)\AutopilotConfig\BitlockerStartupkey.tag" -Value "Installed"