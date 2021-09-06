$projectName = ".\vtt_app"
$installDir = "$projectName\installers"

function printLine() {
    echo "---------------------------------------"
}
function cleanupAndExit($exitCode) {
    echo "Exiting: $exitcode"
    printLine
    printLine
    cd ..
    exit $exitCode
}
function installFromURL($name, $versionCMD, $URL, $installerName) {
    $version = $null;
    try {
        $version = Invoke-Expression $versionCMD
    }
    catch {}

    if ($version) {
        echo "Found $name $version"
    }
    else {
        $installerFilePath = "$installDir\$installerName"
        echo "$name not installed"
        if (-not (Test-Path -Path $installerFilePath -PathType Leaf)) {
            echo "Installer not found"
            echo "Downloading installer"
            wget $URL -outfile $installerFilePath
            echo "Installer downloaded"
        }
        else {
            echo "Installer found"
        }
        echo "Installing $name"
        $exitCode = (Start-Process -FilePath $installerFilePath -Wait -Passthru).ExitCode
        if ($exitCode -ne 0) {
            echo "Installation terminated"
            cleanupAndExit($exitCode)
        }
        $version = Invoke-Expression $versionCMD
        echo "Completed installation of $name $version"
    }
    printLine
}
function createProjectDirectory() {
    # Create project directory
    echo "Creating Project Directory"
    if (-not(Test-Path -Path $projectName)) {
        mkdir $projectName
        echo "Created $projectName"
    }
    else {
        echo "Found $projectName"
    }
    if (-not(Test-Path -Path $installDir)) {
        mkdir $installDir
        echo "Creatied $installDir"
    }
    else {
        echo "Found $installDir"
    }
    printLine
}

printLine
printLine
createProjectDirectory
cd $projectName
# Install dependencies
installFromURL "node" "node -v" "https://nodejs.org/dist/v14.17.6/node-v14.17.6-x86.msi" "node_installer.msi"
installFromURL "git" "git --version" "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe" "git_installer.exe"
installFromURL "mongoDB" "(& 'c:\program files\mongodb\server\4.4\bin\mongod.exe' --version)[0] "  "https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-5.0.2-signed.msi" "mongodb_installer.msi"

# Clone projects from git
$gitRepoURLS =
"https://github.com/vtt-app/vtt_server.git",
"https://github.com/vtt-app/vtt_dev_client.git",
"https://github.com/vtt-app/vtt_client.git",
"https://github.com/vtt-app/vtt_shared.git",
"https://github.com/Arik13/node_utility.git",
"https://github.com/Arik13/ts_utility.git";

function cloneGitRepo($URL) {
    echo "Cloning $([System.IO.Path]::GetFileNameWithoutExtension($URL))"
    git clone $URL
    printLine
}

function installNodePackages($name) {
    cd $name
    echo "installing $name node packages"
    npm i
    cd ..
    printLine
}

$projNames = $gitRepoURLS | % {[System.IO.Path]::GetFileNameWithoutExtension($_) }


$gitRepoURLS | % { cloneGitRepo($_) }
$projNames | % { installNodePackages($_) }
# echo $projNames
# $outputFile = Split-Path $outputPath -leaf

# git clone "https://github.com/vtt-app/vtt_server.git"
# git clone "https://github.com/vtt-app/vtt_dev_client.git"
# git clone "https://github.com/vtt-app/vtt_client.git"
# git clone "https://github.com/vtt-app/vtt_shared.git"
# git clone "https://github.com/Arik13/node_utility.git"
# git clone "https://github.com/Arik13/ts_utility.git"

cleanupAndExit 0