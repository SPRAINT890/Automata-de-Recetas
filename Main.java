import java.io.*;
import java.nio.charset.StandardCharsets;

public class Main {
  public static void main(String[] args) throws Exception {
    Reader r = (args.length > 0)
      ? new InputStreamReader(new FileInputStream(args[0]), StandardCharsets.UTF_8)
      : new InputStreamReader(System.in, StandardCharsets.UTF_8);

    Lexer lexer = new Lexer(r);
    parser p = new parser(lexer);

    try {
      p.parse();
      System.out.println("\n===== RESULTADO =====");
      System.out.println(p.result);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
