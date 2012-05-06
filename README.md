FacebookStalker
===============

This is a nifty Cocoa application that persists a connection to Facebook Chat in the background in order to build an exhaustive log of everyone who signs on/off, sends you messages, etc.  This ability will allow you to easily answer the natural question, "for how long has this person been online?" The automatic reconnect feature allows the application to stay running from the moment you boot up to the moment you shut down, 24/7.  Of course, this comes with the side effect that you will always be signed in to Facebook Chat, but to some this is already near-reality.

Per-Buddy Notifications
=======================

FacebookStalker also includes an *extreme* stalker feature, know as notifications.  With this feature, you can utilize Growl notifications for the sake of being notified about the presence of particularly selected individuals.  The app also includes an optional feature to receive Growl notifications in the event of incoming messages.

Under the Hood
==============

The FacebookStalker application uses the [XMPPFramework](https://github.com/robbiehanson/XMPPFramework) in order to connect and communicate with Facebook.  Facebook currently supports standard XMPP authentication, meaning that XMPPFramework alone is able to authenticate with it.

FacebookStalker uses CoreData for storing log info, buddy list information, and log flags.  The log and notification windows display live information using Key-Value Observation on NSManagedObject instances, which is optimal for such a situation.  I have not worked with CoreData prior to this project, so please excuse any features which I chose to ignore.

License
=======

All of the original code in this project is under the BSD license.

Copyright (c) 2012, Alex Nichol.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.