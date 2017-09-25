setToolTips = function() {
    cy.cxtmenu({
        selector: 'node',
        zIndex: 20000,
        menuRadius: 75,
        activePadding: 10,
        fillColor: 'rgba(0, 0, 0, 0.9)',
        openMenuEvents: 'cxttapstart taphold',
        commands: [
          {
            content: '<span class="icon-arrow-right"></span><label>Expand</label>',
            select: function(){
              insertNewElements(this);
            }
          },

          {
            content: '<span class="icon-remove destructive-light"></span><label class="">Re-Center</label>',
            select: function(){
              var targetId = this.id();
              window.location.href = "/cytoscape/funding.xqy?accessionNumber="+targetId;
            }
          },

          {
            content: '<span class="icon-remove destructive-light"></span><label class="">Remove</label>',
            select: function(){
              cy.remove( this );
            }
          },

          {
            content: '<span class="icon-remove destructive-light"></span><label class="">Cancel</label>'
          }

        ]
      });
    
    
    cy.elements('node').qtip({
        zIndex: 1000,
        content: {
            text: function(){
                var tip = this._private.data.tip;
                var parsed = tip;
                if (tip.startsWith("&lt;")) {
                    parsed = $('<div/>').html(tip).text();
                }
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
}

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
            'background-color' : '#009900',
            'color' : '#009900',
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
        minNodeSpacing: 50,
        levelWidth : function() {
            return 3;
        },
        concentric : function(node) {
            return node._private.data.ring;
        }
    }

});


//cy.$('.ured, .tr, .r2').on('tap', function(evt){
//        insertNewElements(this);

//        this.remove();

//        var targetId = this.id();
//        window.location.href = "/cytoscape/funding.xqy?accessionNumber="+targetId;
//});


setToolTips();

insertNewElements = function(parentNode) {
    var newElements = getNewElementsAjax(parentNode);
}

getNewElementsAjax = function(parentNode) {
    var url = "/cytoscape/ajax/getMoreNodes.xqy?accessionNumber="+parentNode.id();
    $.ajax({
        url: url,
        context: document.body
    }).done(function(data) {
        cy.add(data);
        setToolTips();
        cy.elements().layout({
            name: 'concentric'
        });
    });
}
