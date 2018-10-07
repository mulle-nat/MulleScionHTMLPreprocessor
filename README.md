# MulleScionHTMLPreprocessor

🥣 A Preprocessor for HTML that converts &lt;objc> and other tags to MulleScion {% %}

Write your [MulleScion](/mulle-kybernetik/MulleScion) template code in HTML
lookalike tags. Now reformat the HTML document and it doesn't destroy your
template code (as much).

> Check the [Wiki](mulle-nat/MulleScionHTMLPreprocessor/wiki) for editor setup help.


## Tags

Tag pairs enclose template content. The tag-pairs are translated to MulleScion
handlebars. There is no syntax check done on the text following the tag
identifier.

Tag Opener          | Closer     | Translates to
--------------------|------------|-------------------------
`<block>`           | `</block>` | `{% block %}` `{% endblock %}`
`<else/>`           |            | `{% else %}`
`<if expr>`         | `</if>`    | `{% if expr %}` `{% endif %}`
`<for var in expr>` | `</for>`   | `{% for var in expr %}` `{% endfor %}`
`<objc>`            | `<objc>`   | `{% `  ` %}`
`<while expr>`      | `</while>` | `{% while expr %}` `{% endwhile %}`

`objc` is useful to add Objective-C code in the `<head>` section of the HTML
document, but it can be placed anywhere.
The other tags are more useful in the `<body>` section.

> #### Notes
>
> * `<block>` is experimental, it might get removed
> * `<else/>` has no closer.


## Example

 ```
 <html>
  <head>
    <objc>
       x = @"Hello World";
    </objc>
  </head>
  <body>
    <if x>
       <h1>{{ x }}</h1>
    <else/>
       <h1>I have nothing to say</h1>
    </if>
  </body>
</html>
```

## Hide the uglies in HTML preview

Unknown tags shouldn't get rendered by the browser. Therefore there is nothing to do for
most tags. The text between `<objc>` and `</objc>` can be hidden with CSS:

```
<style type="text/css">
 objc { display: none; white-space: pre; }
</style>
```

## Usage

Instantiate `[[MulleScionHTMLPreprocessor new] autorelease]` and install it with `-[MulleScionParser setPreprocessor:]`. Now you can call `-[MulleScionParser template]` to get the pre-processed and parsed template.

