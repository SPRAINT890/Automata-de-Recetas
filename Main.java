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
      if (p.recetario != null) {
        p.recetario.imprimir();
      } else {
        System.out.println("No se pudo procesar el recetario.");
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
