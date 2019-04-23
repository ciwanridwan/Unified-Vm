import QtQuick 2.4
import QtQuick.Controls 1.3

Item {
    id: component
    property alias model: filterModel

    property QtObject sourceModel: undefined
    property string filter: ""
    property string property: ""
    property bool withLower: false
    property int maxSuggestion: 5
    property int minChars: 2

    Connections {
        onFilterChanged: invalidateFilter()
        onPropertyChanged: invalidateFilter()
        onSourceModelChanged: invalidateFilter()
    }

    Component.onCompleted: {
        invalidateFilter();
        if (withLower==true) lowercaseModel(sourceModel);
    }

    ListModel {
        id: filterModel
    }

    // filters out all items of source model that does not match filter
    function invalidateFilter() {
        if (sourceModel === undefined)
            return;
        filterModel.clear();

        if (!isFilteringPropertyOk()) return;
        if (withLower===false){
            for (var i = 0; i < sourceModel.count; ++i) {
                var item = sourceModel.get(i);
                if (isAcceptedItem(item)) filterModel.append(item);
            }
        } else {
            for (var o = 0; o < lowerModel.count; ++o) {
                var val = lowerModel.get(o);
                if (isAcceptedItem(val)) filterModel.append(val);
            }
        }

    }

    // returns true if item is accepted by filter
    function isAcceptedItem(item) {
        if (item[this.property] === undefined) return false;
        if (item[this.property].match(this.filter) === null) return false;
//        if (this.filter.length < minChars) return false;
        if (filterModel.count > maxSuggestion) return false;
        return true;
    }

    // checks if it has any sence to process invalidating based on property
    function isFilteringPropertyOk() {
        if(this.property === undefined || this.property === "") return false;
        return true;
    }

    ListModel {id: lowerModel}

    function lowercaseModel(model){
        lowerModel.clear();
        if (model===undefined) return;
        if (model.count < 1) return;
        var lenght = model.count
        for (var c=0; c < lenght; c++){
            var item = model.get(c);
            lowerModel.append({'name' : item.toLowerCase()});
        }
//        return model;
    }

}

