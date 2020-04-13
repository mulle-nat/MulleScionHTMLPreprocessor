//
//  MulleScionHTMLPreprocessor.m
//  MulleScion
//
//  Created by Nat! on 07.10.18.
//  Copyright © 2018 Mulle kybernetiK. All rights reserved.
//
#define _DEFAULT_SOURCE  // use for strcasecmp on linux

#import "MulleScionHTMLPreprocessor.h"

#import "import-private.h"
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <string.h>


@implementation MulleScionHTMLPreprocessor



//
// assumes HTML is correct
// assumes there is no space between '<'|'</' and the identifier
// assumes there is no space between '<' and '/' for '</' identifier
// assumes there is no space between '/' and '>' for identifier .. '/>'
//
// parses and ignores comments
// will trip up >= (so use gt, ge)
//
enum parser_state
{
   expect_open,
   open_found,
   identifier_found,
   expect_comment,
   comment_found,
   expect_closer,
   expect_closer2,
   expect_comment_closer,
   expect_comment_closer2,
};


static int   preprocess( struct mulle__buffer*in, struct mulle_buffer *out)
{
   unsigned int        c;
   enum parser_state   state;
   size_t              file_start;
   size_t              file_end;
   size_t              tag_start;
   size_t              tag_end;
   size_t              content_end;
   size_t              identifier_start;
   size_t              identifier_end;
   int                 len;
   unsigned int        identifier_first_char;
   int                 backslash;   // 1 head, 2 tail, 3 both
   static char         tmp[ 32];

   backslash             = -1;
   tag_start             =
   identifier_start      =
   identifier_end        =
   content_end           = (size_t) -1;
   identifier_first_char = 0;

   file_start = _mulle__buffer_get_seek( in);
   state      = expect_open;

   /*
    * do not copy anything, until we find something to edit
    *
    * continue : get next
    *
    * We know:
    *    fs: file start (or last te)
    *
    * We want to get:
    *    ts: tag start
    *    is: identifier start
    *    ie: identifier end
    *    cs: content start (always ie)
    *    ce: content end
    *    te: tag end
    *
    * ....<identifier...text.../>...
    * |   ||         |         | |
    * |   |is        ie        ce|
    * fs  ts         cs          te
    *
    * ....</identifier>...
    * |   | |         ||
    * |   | is       ie|
    * fs  ts            te
    *
    */

   while( (c = _mulle__buffer_next_byte( in)) != -1)
   {
      switch( state)
      {
      case expect_open :
         if( c != '<')
         {
            if( _mulle__buffer_find_byte( in, '<') == -1)
               goto done;

            c = _mulle__buffer_next_byte( in);
            assert( c == '<');
         }
         state             = open_found;
         backslash         = 0;
         identifier_start  = (size_t) -1;
         tag_start         = _mulle__buffer_get_seek( in) - 1;
         continue;

      case open_found :
         if( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')
         {
            identifier_first_char = c;
            identifier_start      = _mulle__buffer_get_seek( in) - 1;
            state                 = identifier_found;
            continue;
         }
         if( c == '-')
         {
            state = expect_comment;
            continue;
         }
         if( c == '/')
         {
            if( ! backslash)
            {
               backslash = 1; // starting backslash
               continue;
            }
         }
         if( c != '<')
            state = expect_open;  // garbage ? lets ignore
         continue;

      case identifier_found :
         if( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_')
            continue;

         identifier_end = _mulle__buffer_get_seek( in);
         content_end    = (size_t) -1;
         state          = expect_closer;
         // fall through

      case expect_closer :
         // snarf up stuff until '/' or '>'
         if( c == '/')
         {
            content_end = _mulle__buffer_get_seek( in) - 1;
            state       = expect_closer2;
            continue;
         }
         if( c != '>')
            continue;
         // fall through

      case expect_closer2 :
         if( c != '>')
         {
            if( content_end  != (size_t) -1)
            {
               if( c == '/')
               {
                  content_end = _mulle__buffer_get_seek( in) - 1;
                  backslash  |= 2;
               }
               else
               {
                  state = expect_closer;
                  content_end = (size_t) -1;
               }
            }
            else
               state = expect_open;
            continue;
         }

         if( identifier_start == (size_t) -1)
         {
            state = expect_open;
            continue;
         }

         if( content_end == (size_t) -1)
            content_end = _mulle__buffer_get_seek( in) - 1;
         break;

      // comment handling
      case expect_comment :
         if( c == '-')
            state = comment_found;
         else
            state = expect_closer;
         continue;

      case comment_found :
          if( c == '-')
             state = expect_comment_closer;
          continue;

      case expect_comment_closer :
         if( c == '-')
            state = expect_comment_closer2;
         else
            state = comment_found;
         continue;

      case expect_comment_closer2 :
         if( c != '>')
         {
            state = comment_found;
            continue;
         }
         state = expect_open;
         continue;
      }

      state = expect_open;

      /*
       * Here we are at the end of a <identifier ...> or </identifier>
       * see if its our identifier. If no, just keep going
       */
      len = (int) (identifier_end - identifier_start) - 1;

      // check if identifier is one of ours
      // <block></block> -> {% block %} {% endblock %}
      // <else/>         -> {% else %}
      // <for></for>     -> {% for %} {% endfor %}
      // <if></if>       -> {% if %} {% endif %}
      // <objc>          -> {%
      // </objc>         -> %}
      // <while></while> -> {% while %} {% endwhile %}
      // trivial check for "not our identifier"

      if( len > 5)
         continue;

      switch( identifier_first_char)
      {
      case 'b' :
      case 'e' :
      case 'f' :
      case 'i' :
      case 'o' :
      case 'w' :
         break;

      default:
         continue;
      }

      tag_end = _mulle__buffer_get_seek( in);
      _mulle__buffer_set_seek( in, MULLE_BUFFER_SEEK_SET, identifier_start);
      _mulle__buffer_next_bytes( in, tmp, len);
      _mulle__buffer_set_seek( in, MULLE_BUFFER_SEEK_SET, tag_end);
      tmp[ len] = 0;

      if( strcasecmp( tmp, "block") &&
          strcasecmp( tmp, "else") &&
          strcasecmp( tmp, "for") &&
          strcasecmp( tmp, "if") &&
          strcasecmp( tmp, "objc") &&
          strcasecmp( tmp, "while"))
      {
         continue;
      }

      /* so it is one of our tags
         1. copy from file_start to tag_start to out
         2. add {%
         3. possibly add "end" prefix to identifier
         4. copy rest
         5. add %}
         Special handling for <objc> and </objc>
      */
      mulle_buffer_add_buffer_range( out, in, file_start, tag_start - file_start);
      if( identifier_first_char == 'o')
         mulle_buffer_add_string( out, backslash ? "%} " : "{% ");
      else
      {
         mulle_buffer_add_string( out, "{% ");
         if( backslash)
         {
            if( backslash & 1)
               mulle_buffer_add_string( out, "end");
            mulle_buffer_add_buffer_range( out, in, identifier_start, identifier_end - identifier_start - 1);
         }
         else
            mulle_buffer_add_buffer_range( out, in, identifier_start, content_end - identifier_start);
         mulle_buffer_add_string( out, " %}");
      }
      file_start = tag_end;
   }


/*
 * Here we are at the end of the file. If there is anything in
 * the output buffer we now flush the rest into it. Otherwise
 * the input buffer can be used unchanged.
 */
done:
   if( mulle_buffer_get_length( out) == 0)
      return( 0);

   file_end = _mulle__buffer_get_seek( in);
   mulle_buffer_add_buffer_range( out, in, file_start, file_end - file_start);
   return( 1);
}


- (NSData *) preprocessedData:(NSData *) data
{
   struct mulle__buffer  in;
   struct mulle_buffer   out;

   _mulle__buffer_init_with_static_bytes( &in, (void *) [data bytes], [data length]);
   mulle_buffer_init( &out, &mulle_default_allocator);

   if( preprocess( &in, &out))
      data = [NSData dataWithBytes:mulle_buffer_get_bytes( &out)
                            length:mulle_buffer_get_length( &out)];

   // not needed as its static
   //    _mulle__buffer_done( &in, NULL);
   mulle_buffer_done( &out);

   return( data);
}

@end
