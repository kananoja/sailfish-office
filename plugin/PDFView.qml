import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Office.PDF 1.0 as PDF

SilicaFlickable {
    id: base;

    contentWidth: canvas.width;
    contentHeight: canvas.height;

    property alias itemWidth: canvas.width;
    property alias itemHeight: canvas.height;
    property alias document: canvas.document;

    property bool scaled: false;

    signal clicked();
    signal updateSize(real newWidth, real newHeight);

    function zoom(amount, center) {

        var oldWidth = canvas.width;
        var oldHeight = canvas.height;

        canvas.width *= amount;
//         updateTimer.restart();

        if(canvas.width < d.minWidth) {
            canvas.width = d.minWidth;
        }

        if(canvas.width > d.maxWidth) {
            canvas.width = d.maxWidth;
        }

        if(canvas.width == d.minWidth) {
            base.scaled = false;
        } else {
            base.scaled = true;
        }

        contentX += (center.x * canvas.width / oldWidth) - center.x;
        if (canvas.height > height) {
            contentY += (center.y * canvas.height / oldHeight) - center.y;
        }
    }

    PDF.Canvas {
        id: canvas;

        width: base.width;
        height: 10;

        //         PDF.Canvas {
//             id: pdfCanvas;
//             document: pdfDocument;
//             width: base.width;
//             height: 10; // something non-zero to get things going
//             flickable: view;
//        }
        flickable: base;

        PinchArea {
            anchors.fill: parent;
            onPinchUpdated: base.zoom(1.0 + (pinch.scale - pinch.previousScale), pinch.center);
            onPinchFinished: base.returnToBounds();

            MouseArea {
                anchors.fill: parent;
                onClicked: base.clicked();
            }
        }
    }

    children: [
        HorizontalScrollDecorator { color: Theme.highlightDimmerColor; },
        VerticalScrollDecorator { color: Theme.highlightDimmerColor; }
    ]

    QtObject {
        id: d;

        property real minWidth: base.width;
        property real maxWidth: base.width * 2.5;
    }

//     Timer {
//         id: updateTimer;
//
//         interval: 500;
//         repeat: false;
//         onTriggered: base.updateSize(canvas.width, canvas.height);
//     }

    /**
     * The following is a workaround for missing currentItem in
     * QML's PathView.
     */
    Component.onCompleted: {
        if (PathView.isCurrentItem) {
            PathView.view.currentItem = base;
        }
    }

    PathView.onIsCurrentItemChanged: {
        if (PathView.isCurrentItem) {
            PathView.view.currentItem = base;
        }
    }
}
