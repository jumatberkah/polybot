import telebot
import asyncdispatch 
import logging 
import options 
import sam 
import net
import strutils
import ../sql/ban_sql
import ../helper_func/auth


proc userChecker*(b: Telebot, u: Update) {.async} = 
    if not u.message.isSome:
        return
    if not (await canBotRestrict(b, $u.message.get.chat.id, u.message.get.chat)):
        return

    var
        message = u.message.get
        user = message.fromUser.get
        chat = message.chat
        text = "<b>Spammer Terdeteksi!\nID:</b> [<code>" & $user.id & "</code>]"
        success = newMessage(chat.id, text)
    let trs = isSpammer(user.id)
    success.parseMode = "html"
    if chat.kind == "supergroup":
        if trs == $user.id:
            try:
                discard await b.kickChatMember($chat.id, user.id, untildate = 0)
                discard await b.deleteMessage($chat.id, message.messageId)
                discard await b.send(success)
            except IOError:
                discard await b.kickChatMember($chat.id, user.id, untildate = 0)
                discard await b.send(success)
            except:
                discard
        