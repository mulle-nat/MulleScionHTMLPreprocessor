# MulleScionHTMLPreprocessor

🥣 A Preprocessor for HTML that converts `<objc>` and other tags to MulleScion `{%` `%}`

Write your [MulleScion](//github.com/MulleWeb/MulleScion) template code in HTML
lookalike tags. Now reformat the HTML document and it doesn't destroy your
template code (as much).

> Check the [Wiki](//github.com/MulleWeb/MulleScionHTMLPreprocessor/wiki) for editor setup help.


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

> Preprocessor support is available starting with MulleScion version 1859.

```
MulleScionParser *parser;

...
[parser setPreprocessor:[MulleScionHTMLPreprocessor object]];
```


## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleScionHTMLPreprocessor to your project:

```
mulle-sde dependency add --objc --github MulleWeb MulleScionHTMLPreprocessor
```

## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleScionHTMLPreprocessor and
all its dependencies:

```
mulle-sde install --objc --prefix /usr/local \
   https://github.com/MulleWeb/MulleScionHTMLPreprocessor/archive/latest.tar.gz
```

## Author

[Nat!](//www.mulle-kybernetik.com/weblog) for
[Mulle kybernetiK](//www.mulle-kybernetik.com) and
[Codeon GmbH](//www.codeon.de)
