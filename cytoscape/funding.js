var cy = cytoscape({

    container : document.getElementById('cytoscape-container'),

    elements : elements,

    style : [ {
        selector : 'node.tr',
        style : {
            'background-color' : '#FF0000',
            'color' : '#FF0000',
            'label' : 'data(label)'
        }
    }, {
        selector : 'node.ured',
        style : {
            'background-color' : '#00FF00',
            'color' : '#00FF00',
            'label' : 'data(label)'
        }
    }, {
        selector : 'node.r2',
        style : {
            'background-color' : '#0000FF',
            'color' : '#0000FF',
            'label' : 'data(label)'
        }
    }, {
        selector : 'edge.pe',
        style : {
            'width' : 1,
            'line-color' : '#6666FF',
            'color' : '#6666FF',
            'mid-target-arrow-color' : '#6666FF',
            'mid-target-arrow-shape' : 'diamond',
            'mid-target-arrow-fill' : 'filled',
            'source-label' : 'data(predicate)',
            'source-text-offset' : 100
        }
    }, {
        selector : 'edge.ct',
        style : {
            'width' : 1,
            'line-color' : '#FF6666',
            'color' : '#FF6666',
            'mid-target-arrow-color' : '#FF6666',
            'mid-target-arrow-shape' : 'diamond',
            'mid-target-arrow-fill' : 'filled',
            'source-label' : 'data(predicate)',
            'source-text-offset' : 100
        }
    } ],

    layout : {
        name : 'concentric',
        minNodeSpacing: 200,
        levelWidth : function() {
            return 4;
        },
        concentric : function(node) {
            return node._private.data.ring;
        }
    }

});

    cy.elements('.ured').qtip({
        content: {
            text: function(){
                var tip = this._private.data.tip;
                var parsed = $('<div/>').html(tip).text();;
                return parsed;
            }
        },
        show: {
            event: 'mouseover'
        },
        hide: {
            event: 'mouseout'
        }
    });

    cy.elements('.r2').qtip({
        content: {
            text: function(){
                var tip = this._private.data.tip;
                var parsed = $('<div/>').html(tip).text();;
                return parsed;
            }
        },
        show: {
            event: 'mouseover'
        },
        hide: {
            event: 'mouseout'
        }
    });

    cy.elements('.tr').qtip({
        content: {
            text: function(){
                var tip = this._private.data.tip;
                var parsed = $('<div/>').html(tip).text();;
                return parsed;
            }
        },
        show: {
            event: 'mouseover'
        },
        hide: {
            event: 'mouseout'
        }
    });

    cy.$('.ured, .tr, .r2').on('tap', function(evt){
        insertNewElements(this);

//        this.remove();

//        var targetId = this.id();
//        window.location.href = "/cytoscape/funding.xqy?accessionNumber="+targetId;
    });

insertNewElements = function(parentNode) {
    var newElements = getNewElementsAjax(parentNode);
}


getNewElementsAjax = function(parentNode) {
    console.log("ajax");
    $.ajax({
        url: "/cytoscape/ajax/getMoreNodes.xqy",
        context: document.body
      }).done(function(data) {
        console.log("done: " + JSON.stringify(data));
        cy.add(data);
      });
}

getNewElements = function(parentNode) {
    var newDocId = "NewDoc";
    var edgeId = parentNode.id() + "To" + newDocId;
    return [{"classes":"tr","data":{"ring":16,"tip":"New node tooltip","label":"AB123456","id":"AB123456"}},{"classes":"ct","data":{"predicate":"xxxx","target":"AB123456","source":"AD000043","id":"AD000043toAB123456"}}];
}