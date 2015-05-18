protoc --plugin=protoc-gen-as3=%~dp0\protoc-gen-as3.bat -I=%~dp0\proto --as3_out=%~dp0\src %~dp0\proto\protocol.proto

pause