/*
 * Copyright (C) 2013-2014 Jolla Ltd.
 * Contact: Robin Burchell <robin.burchell@jolla.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 only.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.kde.calligra 1.0 as Calligra

DocumentPage {
    id: page;

    attachedPage: Component {
        SpreadsheetListPage {
            document: doc;
        }
    }

    Calligra.Document {
        id: doc;
    }

    Calligra.View {
        id: v;

        width: page.width;
        height: page.height;

        document: doc;
    }


    SilicaFlickable {
        id: f;

        width: page.width;
        height: page.height;

        Calligra.ViewController {
            id: controller;
            view: v;
            flickable: f;
        }

        children: [
            HorizontalScrollDecorator { color: Theme.highlightDimmerColor; },
            VerticalScrollDecorator { color: Theme.highlightDimmerColor; }
        ]

        PinchArea {
            anchors.fill: parent;

            onPinchUpdated: {
                var newCenter = mapToItem( f, pinch.center.x, pinch.center.y );
                controller.zoomAroundPoint(pinch.scale - pinch.previousScale, newCenter.x, newCenter.y);
            }
            onPinchFinished: controller.zoomTimeout();

            Calligra.LinkArea {
                anchors.fill: parent;
                document: doc;
                onClicked: page.open = !page.open;
                onLinkClicked: Qt.openUrlExternally(linkTarget);
                controllerZoom: controller.zoom;
            }
        }
    }

    busy: doc.status != Calligra.DocumentStatus.Loaded;
    source: doc.source;
    indexCount: doc.indexCount;

    onStatusChanged: {
        //Delay loading the document until the page has been activated.
        if(status == PageStatus.Active) {
            doc.source = page.path;
        }

        //Reset the position when we change sheets
        if(status == PageStatus.Activating) {
            f.contentX = 0;
            f.contentY = 0;
        }
    }
}
