name := "akka-server"

version := "1.0.0"

scalaVersion := "2.11.6"

libraryDependencies ++= Seq(
                             "ch.qos.logback"      %   "logback-classic" % "1.1.2",
                             "ch.qos.logback"      %   "logback-core"    % "1.1.2",
                             "com.typesafe.akka"   %  "akka-actor_2.11"  % "2.3.9",
                             "com.typesafe.akka"   %  "akka-slf4j_2.11"  % "2.3.9",
                             "com.google.protobuf" %  "protobuf-java"    % "2.4.1"
                           )
