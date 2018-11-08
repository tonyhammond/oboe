import java.util.*;
import java.io.*;
/***
 *This program demonstrates how to use the Properties class. It uses
 *some methods added in JDK 1.2 and will not work with JDK 1.1. You
 *can add a key-value pair to a properties file using
 *         java PropertiesExample filename set key value
 *and delete a key using
 *         java PropertiesExample filename del key
 *and list the property file using
 *         java PropertiesExample filename list
 *If the file does not exist when you add a key-value pair, it is created.
 ***/
public class PropertiesExample {
  public static final int SET  = 1;
  public static final int DEL  = 2;
  public static final int LIST = 3;

  public static void printUsage() {
      System.err.println(
         "Usage: PropertiesExample filename list|set|del [key] [value]");
  }
   
  public static void main(String[] args) {
    File file;
    Properties properties;
    String filename, key = null, value = null;
    InputStream input;
    OutputStream output;
    int action;

    if(args.length < 1) {
      printUsage();
      return;
    }
     
    filename = args[0];
    file = new File(filename);

    try {
      if(args[1].equals("list")) {
        action = LIST;
      } else if(args[1].equals("set")) {
        action = SET;

        if(args.length < 4) {
          printUsage();
          return;
        }
         
        if(!file.exists()) {
          System.out.println(filename + " does not exist.  Creating file.");
          file.createNewFile();
        }
         
        key   = args[2];
        value = args[3];
      } else if(args[1].equals("del")) {
        action = DEL;

        if(args.length < 3) {
          printUsage();
          return;
        }
         
        if(!file.exists()) {
          System.err.println(filename + " does not exist!");
          return;
        }
         
        key = args[2];
      } else {
        printUsage();
        return;
      } 
       
      properties = new Properties();
      properties.load(input = new FileInputStream(file));
      input.close();

      switch(action) {
      case SET: properties.setProperty(key, value); break;
      case DEL: properties.remove(key); break;
      case LIST: properties.list(System.out); break;
      }
       
      if(action != LIST) {
        properties.store(output = new FileOutputStream(file), null);
        output.close();
      }
    } catch(IOException e) {
      e.printStackTrace();
      return;
    }
  }  

}

