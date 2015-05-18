protoc -I=%~dp0\proto --java_out=%~dp0\src\main\java %~dp0\proto\packet.proto

pause