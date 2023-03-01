class FunHelp {
  int checkStatusUser(String input){
    int result = 3;

    switch (input.toLowerCase()) {
      case "mdm":
        result = 1;
        break;
      case "adm":
        result = 2;
        break;
      case "usr":
        result = 3;
        break;
    }

    return result;
  }
}