// This file is executed on the first start of Plasma.
// see https://develop.kde.org/docs/plasma/scripting/ for how this works

// iterate over all panels
for (panel in panelIds) {
  var panel = panelById(panelIds[panel]);
  for (widget in panel.widgetIds) {
    var widget = panel.widgetById(panel.widgetIds[widget]);
    // TODO: we can't configure favorits in kickoff this way
    // org.kde.kickoff had favoriteApps, but they got favoritesPortedToKAstats
    
    // pin apps to the taskbar
    if (widget.type === "org.kde.plasma.icontasks") {
      widget.currentConfigGroup = ["General"];
      widget.writeConfig("launchers", ["applications:systemsettings.desktop", "applications:org.kde.dolphin.desktop", "applications:firefox.desktop"]);
    }
  }
}
