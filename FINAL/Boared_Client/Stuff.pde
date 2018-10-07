int extractId(String chunk) {
  int i = chunk.indexOf("|");
  if (i > 0) {
    return parseInt(chunk.substring(0, i));
  }
  return -1;
}
