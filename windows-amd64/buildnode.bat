:: Node Build Script 
@echo off
cd %userprofile%

SET BINTAG=v1.0.40
SET CONFTAG= BoN-ph2-w1

:: Create Paths
if not exist "%GOPATH%\src\github.com\ElrondNetwork" mkdir %GOPATH%\src\github.com\ElrondNetwork
cd %GOPATH%\src\github.com\ElrondNetwork

:: Delete previously cloned repos
@RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-go"
@RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-config"

:: Clone elrond-go & elrond-config repos
git clone --branch %BINTAG% https://github.com/ElrondNetwork/elrond-go
git clone --branch %CONFTAG% https://github.com/ElrondNetwork/elrond-config

cd %GOPATH%\src\github.com\ElrondNetwork\elrond-config
copy /Y *.* %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config

:: Build the node executable
cd %GOPATH%\pkg\mod\cache
del /s *.lock
cd %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node
@echo on
SET GO111MODULE=on
go mod vendor
go build -i -v -ldflags="-X main.appVersion=%BINTAG%"
@echo off

:: Build the key generator & run it
cd %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\keygenerator
go build
keygenerator.exe

:: Copy keys in their proper place & in backup location
copy /Y initialBalancesSk.pem %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config
copy /Y initialNodesSk.pem %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config

mkdir %userprofile%\node-pem-backup
copy /Y initialBalancesSk.pem %userprofile%\node-pem-backup
copy /Y initialNodesSk.pem %userprofile%\node-pem-backup

:: Naming node
set /P nodename=What is your desired name for your Node?
(
echo [Preferences]
echo     # NodeDisplayName represents the friendly name a user can pick for his node in the status monitor
echo       NodeDisplayName = "%nodename%"
)>"%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config\prefs.toml"

:: Show Node Version
cd %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node
echo Current Node Version:
node.exe --version
timeout 10
