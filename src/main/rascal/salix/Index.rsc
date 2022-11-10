module salix::Index


import salix::Core;
import salix::HTML;
import salix::Extension;
import String;


void(&T) withIndex(str myTitle, str myId, void(&T) view, list[Extension] exts = [], list[str] css = [], list[str] scripts = []) {
  return void(&T model) {
     index(myTitle, myId, () {
       view(model);
     }, exts=exts, css=css, scripts=scripts);
  };
}


void index(str myTitle, str myId, void() block, list[Extension] exts = [], list[str] css = [], list[str] scripts = []) {
  html(() {
    head(() {
      title_(myTitle);
      
      for (Extension e <- exts) {
        for (Asset a <- e.assets) {
          switch (a) {
            case css(str c): link(\rel("stylesheet"), href(c));
            case js(str j): script(\type("text/javascript"), src(j));
            default: throw "Unknown asset: <a>";
          }
        }
      }
      
      for (str c <- css) {
        link(\rel("stylesheet"), href(c));
      }
      
      for (str s <- scripts + ["/salix/salix.js"]) {
        script(\type("text/javascript"), src(s));
      }
      
      str src = "const app = new Salix();\n";
      
      for (Extension e <- exts) {
        src += "register<capitalize(e.name)>(app);\n";
      }
      
      script("document.addEventListener(\"DOMContentLoaded\", function() {
             '  const app = new Salix(\"<myId>\");
             '  <for (Extension e <- exts) {>
             '  register<capitalize(e.name)>(app);
             '  <}>
             '  app.start();
             '});");
    });
    
    body(block);
  });
}

