package echoServer

import (
  "fmt"
  "net"
  "os"
  "strconv"
  "bytes"
)

const (
  CONN_HOST = ""
  CONN_PORT = "3333"
  CONN_TYPE = "tcp"
)

func Server() {
  // listen for incoming connections
  l, err := net.Listen(CONN_TYPE, ":"+CONN_PORT)
  if err != nil {
    fmt.Println("Error listening: ",err.Error())
    os.Exit(1)
  }

  // close the listener when the application closes
  defer l.Close()
  fmt.Println("Listening on " + CONN_HOST + ":" + CONN_PORT)
  for {
    // Listen for an incoming connection
    conn, err := l.Accept()
    if err != nil {
      fmt.Println("Error accepting: ", err.Error())
      os.Exit(1)
    }

    // logs the incoming message
    fmt.Println("Received message %s -> %s \n",
      conn.RemoteAddr(), conn.LocalAddr())

    // handle connections in a new go routine
    go handleRequest(conn)
  }
}

// handles incoming requests
func handleRequest(conn net.Conn) {
  // make buffer to hold incoming data
  buf := make([]byte,1024)

  // Defer the closure of the connection when we get out of the scope
  defer conn.Close()

  // read the incoming connection into the buffer
  reqLen, err := conn.Read(buf)
  if err != nil {
    fmt.Println("Error reading: Error()")
    return
  }

  // Build the message
  message := "Hi, I received your message! It was "
  message += strconv.Itoa(reqLen)
  message += " bytes long. This is the content: \""
  n := bytes.Index(buf, []byte{0})
  message += string(buf[:n-1])
  message += "\"! Bye."

  // Write the message in the connection channel
  conn.Write([]byte(message))
}
