package bootstrap.liftweb

import net.liftweb.db.{DefaultConnectionIdentifier, DB, StandardDBVendor}
import net.liftweb.mapper.Schemifier
import net.liftweb.util._
import net.liftweb.common._
import net.liftweb.http._
import net.liftweb.sitemap._
import leedm777.bacon.model._

/**
 * A class that's instantiated early and run.  It allows the application
 * to modify lift's environment
 */
class Boot extends Loggable {
  def boot {
    // where to search snippet
    LiftRules.addToPackages("leedm777.bacon")

    // setup mapper
    for (driverName <- Props.get("db.driver"); url <- Props.get("db.url")) {
      val user = Props.get("db.user")
      val password = Props.get("db.password")
      val vendor = new StandardDBVendor(driverName, url, user, password)
      DB.defineConnectionManager(DefaultConnectionIdentifier, vendor)
      Schemifier.schemify(true, Schemifier.infoF _, Player)
      logger.info("Database configured")
    }

    // Build SiteMap
    val entries =
      Menu.i("jQuery counter") / "index" ::
        Menu.i("Bacon counter") / "bacon-counter" ::
        Menu.i("jQuery sum") / "jquery-sum" ::
        Menu.i("Bacon sum") / "bacon-sum" ::
        Nil

    // set the sitemap.  Note if you don't want access control for
    // each page, just comment this line out.
    LiftRules.setSiteMap(SiteMap(entries: _*))

    //Show the spinny image when an Ajax call starts
    LiftRules.ajaxStart =
      Full(() => LiftRules.jsArtifacts.show("ajax-loader").cmd)

    // Make the spinny image go away when it ends
    LiftRules.ajaxEnd =
      Full(() => LiftRules.jsArtifacts.hide("ajax-loader").cmd)

    // Force the request to be UTF-8
    LiftRules.early.append(_.setCharacterEncoding("UTF-8"))

    // Use HTML5 for rendering
    LiftRules.htmlProperties.default.set((r: Req) => new Html5Properties(r.userAgent))

    ResourceServer.allowedPaths = { //ResourceServer.allowedPaths orElse {
      case js@("js" :: _) if js.last.endsWith(".js") => true
      case js@("css" :: _) if js.last.endsWith(".css") => true
    }

    logger.info("Ready to serve")
  }
}
