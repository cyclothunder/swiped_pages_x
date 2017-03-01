// ekke (Ekkehard Gentz) @ekkescorner
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import "common"
import "pages"

// This app demonstrates HowTo use Qt 5.8 and Qt Quick Controls 2.1, High DPI and more
// This app is NOT a production ready app
// This app's goal is only to help you to understand some concepts
// see blog http://j.mp/qt-x to learn about Qt 5.8 for Material - styled Android or iOS Apps
// learn about this swiped_pages_x app from this article: http://bit.ly/qt-swiped-pages-x
// ekke (Ekkehard gentz) @ekkescorner

ApplicationWindow {
    id: appWindow
    // visibile must set to true - default is false
    visible: true
    // primary and accent properties:
    property variant primaryPalette: myApp.defaultPrimaryPalette()
    property color primaryLightColor: primaryPalette[0]
    property color primaryColor: primaryPalette[1]
    property color primaryDarkColor: primaryPalette[2]
    property color textOnPrimaryLight: primaryPalette[3]
    property color textOnPrimary: primaryPalette[4]
    property color textOnPrimaryDark: primaryPalette[5]
    property string iconOnPrimaryLightFolder: primaryPalette[6]
    property string iconOnPrimaryFolder: primaryPalette[7]
    property string iconOnPrimaryDarkFolder: primaryPalette[8]
    property variant accentPalette: myApp.defaultAccentPalette()
    property color accentColor: accentPalette[0]
    property color textOnAccent: accentPalette[1]
    property string iconOnAccentFolder: accentPalette[2]
    Material.primary: primaryColor
    Material.accent: accentColor
    // theme Dark vs Light properties:
    property variant themePalette: myApp.defaultThemePalette()
    property color dividerColor: themePalette[0]
    property color cardAndDialogBackground: themePalette[1]
    property real primaryTextOpacity: themePalette[2]
    property real secondaryTextOpacity: themePalette[3]
    property real dividerOpacity: themePalette[4]
    property real iconActiveOpacity: themePalette[5]
    property real iconInactiveOpacity: themePalette[6]
    property string iconFolder: themePalette[7]
    property int isDarkTheme: themePalette[8]
    property color flatButtonTextColor: themePalette[9]
    property color popupTextColor: themePalette[10]
    // Material.dropShadowColor  OK for Light, but too dark for dark theme
    property color dropShadow: isDarkTheme? "#E4E4E4" : Material.dropShadowColor
    onIsDarkThemeChanged: {
        if(isDarkTheme == 1) {
            Material.theme = Material.Dark
        } else {
            Material.theme = Material.Light
        }
    }
    // font sizes - defaults from Google Material Design Guide
    property int fontSizeDisplay4: 112
    property int fontSizeDisplay3: 56
    property int fontSizeDisplay2: 45
    property int fontSizeDisplay1: 34
    property int fontSizeHeadline: 24
    property int fontSizeTitle: 20
    property int fontSizeSubheading: 16
    property int fontSizeBodyAndButton: 14 // is Default
    property int fontSizeCaption: 12
    // fonts are grouped into primary and secondary with different Opacity
    // to make it easier to get the right property,
    // here's the opacity per size:
    property real opacityDisplay4: secondaryTextOpacity
    property real opacityDisplay3: secondaryTextOpacity
    property real opacityDisplay2: secondaryTextOpacity
    property real opacityDisplay1: secondaryTextOpacity
    property real opacityHeadline: primaryTextOpacity
    property real opacityTitle: primaryTextOpacity
    property real opacitySubheading: primaryTextOpacity
    // body can be both: primary or secondary text
    property real opacityBodyAndButton: primaryTextOpacity
    property real opacityBodySecondary: secondaryTextOpacity
    property real opacityCaption: secondaryTextOpacity
    //

    header: SwipeTextTitle {
        id: titleBar
        text: navPane.currentItem? navPane.currentItem.title : qsTr("A simple Swiped - Pages APP")
    }

    // primaryDarkColor is used because FAB can overlap Raised Buttons colored in primaryColor
    FloatingActionButton {
        id: fab
        visible: !navPane.pageValidation[navPane.currentIndex]
        property string imageName: "/done.png"
        z: 1
        anchors.margins: 16
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        imageSource: "qrc:/images/"+iconOnPrimaryDarkFolder+imageName
        backgroundColor: primaryDarkColor
        onClicked: {
            // simulating check isValid()
            // only if valid next page can be swiped to
            navPane.pageValidation[navPane.currentIndex] = 1
            navPane.validationChanged()
            visible = false
        }
    } // FAB

    SwipeView {
        id: navPane
        signal validationChanged()
        // 0: validation failed, 1: validation done
        property var pageValidation: [0,0,0,0,0]
        property int lastIndex: 0
        focus: true
        anchors.fill: parent
        currentIndex: 0
        // currentIndex is the NEXT index swiped to
        onCurrentIndexChanged: {
            fab.visible = !pageValidation[currentIndex]
            if (lastIndex == currentIndex) {
                return
            }
            if (lastIndex > currentIndex) {
                // swiping back
                lastIndex = currentIndex
                return
            }
            // swiping forward
            for (var i = lastIndex; i <= currentIndex; i++) {
                if(!pageValidation[i]) {
                    if(i < currentIndex) {
                        pageNotValid(i+1)
                        lastIndex = i
                        currentIndex = i
                        return
                    }
                }
            } // for
            lastIndex = currentIndex
        }

        // support of BACK key
        property bool firstPageInfoRead: false
        Keys.onBackPressed: {
            event.accepted = navPane.currentIndex > 0 || !firstPageInfoRead
            if(navPane.currentIndex > 0) {
                onePageBack()
                return
            }
            // first time we reached first page
            // user gets Popupo Info
            // hitting again BACK will close the app
            if(!firstPageInfoRead) {
                firstPageReached()
            }
            // We don't have to manually cleanup loaded Page 1+2
            // While shutting down the app loaded Pages will be deconstructed
            // and cleanup called
        }

        // some keyboard shortcuts if:
        // * running on BlackBerry PRIV (Slider with hardware keyboard)
        // * or attached Bluetooth Keyboard
        // Jump to Page 1 (w), 2 (e), 3 (r), 4 (s), 5(d)
        // Goto next page: 'n'
        // Goto previous page: 'p'
        Shortcut {
            sequence: "w"
            onActivated: navPane.goToPage(0)
        }
        Shortcut {
            sequence: "Alt+w"
            onActivated: navPane.goToPage(0)
        }
        Shortcut {
            sequence: "e"
            onActivated: navPane.goToPage(1)
        }
        Shortcut {
            sequence: "Alt+e"
            onActivated: navPane.goToPage(1)
        }
        Shortcut {
            sequence: "r"
            onActivated: navPane.goToPage(2)
        }
        Shortcut {
            sequence: "Alt+r"
            onActivated: navPane.goToPage(2)
        }
        Shortcut {
            sequence: "s"
            onActivated: navPane.goToPage(3)
        }
        Shortcut {
            sequence: "Alt+s"
            onActivated: navPane.goToPage(3)
        }
        Shortcut {
            sequence: "d"
            onActivated: navPane.goToPage(4)
        }
        Shortcut {
            sequence: "Alt+d"
            onActivated: navPane.goToPage(4)
        }
        // n == NEXT
        Shortcut {
            sequence: "n"
            onActivated: navPane.onePageForward()
        }
        // p == PREVIOUS
        Shortcut {
            sequence: "p"
            onActivated: navPane.onePageBack()
        }
        Shortcut {
            sequence: " "
            onActivated: navPane.onePageForward()
        }
        Shortcut {
            sequence: "Shift+ "
            onActivated: navPane.onePageBack()
        }
        function onePageBack() {
            console.log("one BACK current: " + navPane.currentIndex + " last: "+navPane.lastIndex)
            if(navPane.currentIndex == 0) {
                firstPageReached()
                return
            }
            navPane.goToPage(currentIndex - 1)
        } // onePageBack

        function onePageForward() {
            console.log("one FORWARD current: " + navPane.currentIndex + " last: "+navPane.lastIndex)
            if(navPane.currentIndex == 4) {
                lastPageReached()
                return
            }
            navPane.goToPage(currentIndex + 1)
        }

        function goToPage(pageIndex) {
            if(pageIndex == navPane.currentIndex) {
                // it's the current page
                return
            }
            if(pageIndex > 4 || pageIndex < 0) {
                return
            }
            navPane.currentIndex = pageIndex
        } // goToPage

        Loader {
            // index 0
            id: pageOneLoader
            property string title: active? item.title:"..."
            active: navPane.currentIndex == 0 || navPane.currentIndex == 1
            source: "pages/PageOne.qml"
            onLoaded: item.init()
            // would like to call item.cleanup() from here, but there's no 'onUnloading'
            // so cleanup() is called from Component.onDestruction inside item
        }
        Loader {
            // index 1
            id: pageTwoLoader
            property string title: active? item.title:"..."
            active: navPane.currentIndex == 0 || navPane.currentIndex == 1 || navPane.currentIndex == 2
            source: "pages/PageTwo.qml"
            onLoaded: item.init()
        }
        Loader {
            // index 2
            id: pageThreeLoader
            property string title: active? item.title:"..."
            active: navPane.currentIndex == 1 || navPane.currentIndex == 2 || navPane.currentIndex == 3
            source: "pages/PageThree.qml"
            onLoaded: item.init()
        }
        Loader {
            // index 3
            id: pageFourLoader
            property string title: active? item.title:"..."
            active: navPane.currentIndex == 2 || navPane.currentIndex == 3 || navPane.currentIndex == 4
            source: "pages/PageFour.qml"
            onLoaded: item.init()
        }
        Loader {
            // index 4
            id: pageFiveLoader
            property string title: active? item.title:"..."
            active: navPane.currentIndex == 3 || navPane.currentIndex == 4
            source: "pages/PageFive.qml"
            onLoaded: item.init()
        }

    } // navPane

    PageIndicator {
        id: pageIndicator
        count: navPane.count
        currentIndex: navPane.currentIndex

        anchors.bottom: navPane.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    function switchPrimaryPalette(paletteIndex) {
        primaryPalette = myApp.primaryPalette(paletteIndex)
    }
    function switchAccentPalette(paletteIndex) {
        accentPalette = myApp.accentPalette(paletteIndex)
    }

    // we can loose the focus if Menu or Popup is opened
    function resetFocus() {
        navPane.focus = true
    }

    //
    PopupPalette {
        id: popup
        onAboutToHide: {
            resetFocus()
        }
    }

    function firstPageReached() {
        popupInfo.text = qsTr("No more Pages\nFirst Page reached")
        popupInfo.buttonText = qsTr("OK")
        popupInfo.open()
        navPane.firstPageInfoRead = true
    }
    function lastPageReached() {
        popupInfo.text = qsTr("No more Pages\nLast Page reached")
        popupInfo.buttonText = qsTr("OK")
        popupInfo.open()
    }
    function pageNotValid(pageNumber) {
        popupInfo.text = qsTr("Page %1 not valid.\nPlease tap 'Done' Button","").arg(pageNumber)
        popupInfo.buttonText = qsTr("So Long, and Thx For All The Fish")
        popupInfo.open()
    }

    // Unfortunately no SIGNAL if end or beginning reached from SWIPE GESTURE
    // so at the moment user gets no visual feedback
    // TODO Bugreport
    PopupInfo {
        id: popupInfo
        onAboutToHide: {
            popupInfo.stopTimer()
            resetFocus()
        }
    } // popupInfo


} // app window
