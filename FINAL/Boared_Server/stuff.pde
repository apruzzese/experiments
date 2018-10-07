void echo(Client source, String message) {
  for (Map.Entry<String, Client> entry : clients.entrySet()) {
    Client other = entry.getValue();                  
    if (other.ip() != source.ip()) { // ...except for the one we got the message from!
      other.write(message);
    }
  }
}

// ID is the first chunk of a data string...
int extractId(String chunk) {
  int i = chunk.indexOf("|");
  if (i > 0) {
    return parseInt(chunk.substring(0, i));
  }
  return -1;
}

// When a client connects:
void serverEvent(Server s, Client c) {
  
  println("We have a new client: " + c.ip());
  
  // We send it the current WORD:
  c.write("WORD" + SEPARATOR + word + TERMINATOR);
   s.write("COLOR" + SEPARATOR + backcolor + TERMINATOR);
  // We send it the current box configuration:
  String message = "UPDATE" + SEPARATOR; // 
  for (Box b : objects) {
    message += b.serialize() + SEPARATOR;
  }
  message = trim(message) + TERMINATOR; // ...add a terminator!
  
  //println(message);
  c.write(message);
  // and add it to the client list...
  clients.put(c.ip(), c);
}

// When a client disconnects:
void disconnectEvent(Client c) {
  print("We lost a client: " + c.ip());
  // We remove it from the client list...
  if (clients.containsKey(c.ip())) {
    clients.remove(c.ip());
  }
}
