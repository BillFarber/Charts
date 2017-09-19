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
        selector : 'edge',
        style : {
            'width' : 1,
            'line-color' : '#3CC',
            'color' : '#3CC',
            'source-label' : 'data(predicate)',
            'source-text-offset' : 100
        }
    }, {
        selector : 'edge.foobar',
        style : {
            'width' : 1,
            'line-color' : '#C33',
            'color' : '#C33',
            'mid-target-arrow-color' : '#C33',
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
            console.log(node._private.data.ring);
            return node._private.data.ring;
        }
    }

});

    cy.elements('.ured').qtip({
        content: function(){ return 'URED document: ' + this.id() }
    });

    cy.elements('.r2').qtip({
        content: function(){ return 'R2 document: ' + this.id() }
    });

    cy.elements('.tr').qtip({
        content: function(){ return 'TR document: ' + this.id() }
    });
