<#
    .TITLE
        'Custom-InputBox.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        somethingsomething the dark side
    .REFERENCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Remember - Stay Hydrated!'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$yesButton = New-Object System.Windows.Forms.Button
$yesButton.Location = New-Object System.Drawing.Point(75,120)
$yesButton.Size = New-Object System.Drawing.Size(75,23)
$yesButton.Text = 'Yes'
$yesButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $yesButton
$form.Controls.Add($yesButton)

$noButton = New-Object System.Windows.Forms.Button
$noButton.Location = New-Object System.Drawing.Point(150,120)
$noButton.Size = New-Object System.Drawing.Size(75,23)
$noButton.Text = 'Not Yet'
$noButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.noButton = $noButton
$form.Controls.Add($noButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Have you drunk water recently?'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
    $x
}