var cy = cytoscape({

    container : document.getElementById('cytoscape-container'),

    elements : elements,
    // [
    // { data: { id: 'Carl', ring: 8, label: 'C' } },
    // { data: { id: 'Phil', ring: 4, label: 'P' } },
    // { data: { id: 'CarlChild1', source: 'Carl', predicate:'HasASon', target:
    // 'Phil' } }
    // ],

    style : [ {
        selector : 'node',
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
            'mid-target-arrow-color' : '#33C',
            'mid-target-arrow-shape' : 'triangle',
            'mid-target-arrow-fill' : 'filled',
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
        name : 'circle',
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
        content: function(){ return 'R2 document: ' + this.id() },
        position: {
            my: 'top center',
            at: 'bottom center'
        },
        style: {
            classes: 'qtip-bootstrap',
            tip: {
                width: 16,
                height: 8
            }
        }
    });
