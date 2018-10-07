# MulleScionHTMLPreprocessor

🥣 A Preprocessor for HTML that converts &lt;objc> and other tags to MulleScion {% %}

Write your [MulleScion](/mulle-kybernetik/MulleScion) template code in HTML lookalike tags. 
Now reformat the HTML document and it doesn't destroy  your template code (as much).

## Tags

### Tag pairs

Tag pairs enclose template content. The tag-pairs are translated to MulleScion handlebars.
There is no syntax check done on the text following the tag identifier.

Tag Opener          | Closer     | Translates to
--------------------|------------|-------------------------
`<block>`           | `</block>` | `{% block %}` `{% endblock %}`
`<for var in expr>` | `</for>`   | `{% for var in expr %}` `{% endfor %}`
`<if expr>`         | `</if>`    | `{% if expr %}` `{% endif %}`
`<while expr>`      | `</while>` | `{% while expr %}` `{% endwhile %}`
`<objc>`            | `<objc>`   | `{% `  ` %}`

`objc` is useful to add of Objective-C code in the `<head>` section of the HTML document, but it can be placed anywhere.
The other tags are more useful in the `<body>` section. 

> `<block>` is experimental, it might get removed

 

### Single Tag

Tag         | Translates to
------------|---------------------
`<else/>`   | `{% else %}`


## Example

 ```
 <html>
  <head>
    <objc>
       x = @"Hello World";
    </obj>
  </head>
  <body>
    <if x>
       <h1>{{ x }}</h1>
    <else/>
       <h1>I have nothing to say</h1>
    </fi>
  </body>
</html>
```

## Hide the uglies in HTML preview

Unknown tags shouldn't get rendered. The text between `<objc>` and `</objc>` can be hidden with CSS:

```
<style type="text/css">
 objc { display: none; white-space: pre; }
</style>
```

