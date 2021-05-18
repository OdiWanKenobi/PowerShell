<#
    .TITLE
        'Custom-ListBox.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        somethingsomething the dark side
#>

## Loading System.Drawing and System.Windows.Forms .NET classes
## Starts a new Form instance, which allows us to begin adding controls
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

## Assinging values to the 'Text', 'Size,' and 'StartPosition' properties
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Stay Hydrated!'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

## Creating an 'OK' button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

## Creating a 'Cancel' button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

## Customizing the label text on the form window
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Have you drunk water in the last hour?'
$form.Controls.Add($label)

## Creating a list box for users to select from
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 80

## Adding the options 'Yes' and 'No' to the list box
[void] $listBox.Items.Add('Yes')
[void] $listBox.Items.Add('No')

## Tells Windows to open the form on top of all other dialog boxes when it opens
$form.Controls.Add($listBox)
$form.Topmost = $true

## Displays the form in Windows
$result = $form.ShowDialog()

## The 'If' block tells Windows to exit the form once a user selects an option from the list
## And then clicks the 'OK' button or presses the 'Enter' key
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItem
    $x
}

## Creating a new TXT log file everytime the script runs
## Captures the time and the output from the list box
$outputPath = "C:\Output\"
$outputDate = Get-Date -Format 'dd-MMMM-yyyy-HH-mm-ss'
$outputFile = $outputPath + $outputDate + ".txt"
$outputFileDate = Get-Date -UFormat '%d-%B-%Y %H:%M:%S'
$outputFileValue = $outputFileDate + " : " + $x

## Adding captured data to new log TXT file
Add-Content -Path $outputFile -Value  $outputFileValue -Force