/**
 * SyntaxHighlighter for http://alexgorbatchev.com/SyntaxHighlighter/
 * @license
 * Dual licensed under the MIT and GPL licenses.
 */
;(function()
{
    // CommonJS
    typeof(require) != 'undefined' ? SyntaxHighlighter = require('shCore').SyntaxHighlighter : null;

    function Brush()
    {
        var datatypes = 'matrix tuple set mset partition int bool enum false true'
        var extras    = 'total injective bijective surjective maxOccur minOccur minSize size numParts partSize complete maxSize regular maxNumParts maxPartSize minNumParts minPartSize '
        var funcs     = 'defined preImage parts max min range toSet toMSet toRelation toInt allDiff atleast atmost gcc alldifferent_except table';
        var keywords  = 'dim maximising minimising forAll exists sum be by domain in find from function given image indexed intersect freq letting of partial quantifier relation representation subset subsetEq such supset supsetEq that together new type union where branching on';
        var operators = 'all and any between cross in join like not null or outer some';

        this.regexList = [
            { regex: /\$(.*)$/gm,                                   css: 'comments' },
            { regex: new RegExp(this.getKeywords(funcs), 'gm'),     css: 'functions' },
            { regex: new RegExp(this.getKeywords(operators), 'gm'), css: 'color2' },
            { regex: new RegExp(this.getKeywords(datatypes), 'gm'), css: 'color1 bold' },
            { regex: new RegExp(this.getKeywords(extras), 'gm'),    css: 'preprocessor' },
            { regex: new RegExp(this.getKeywords(keywords), 'gmi'), css: 'keyword' }
            ];
    };

    Brush.prototype = new SyntaxHighlighter.Highlighter();
    // Should be the same name as the Title from specification.md of the langauge page converted to lower case.
    Brush.aliases   = ['essence'];

    SyntaxHighlighter.brushes.Essence = Brush;

    // CommonJS
    typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();

