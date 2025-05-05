// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:viajuntos/feature_user/screens/banned_user_page.dart';
import 'dart:convert';

class SnackbarHelper {
  static void showSnackbarFromResponse(BuildContext context, dynamic response) {
    final data = json.decode(response.body);
    final statusCode = response.statusCode;
    final errorMessage =
        data['error_message'] ?? data['message'] ?? 'Unknown error';

    // Determine color based only on status code
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = statusCode >= 200 && statusCode < 300
        ? colorScheme.secondary
        : colorScheme.error;

    // Get the complete server message (use translation if available)
    final message = _getMessageFromResponse(data, statusCode, context);

    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String _getMessageFromResponse(
      Map<String, dynamic> data, int statusCode, BuildContext context) {
    // Handle success cases
    if (statusCode == 200 || statusCode == 201) {
      return data['message'] ?? 'Operation successful';
    }
    String error_message = data['message'];
    if (error_message.contains('{') && error_message.contains('}')) {
      if (error_message.startsWith('User with id') &&
          error_message.contains('does not exist')) {
        return "UserNotFound";
      } else if (error_message.contains("isn't a valid UUID") ||
          error_message.contains("ID is not a valid UUID")) {
        return "InvalidUUID";
      } else if (error_message.contains('already report this user')) {
        return "AlreadyReported";
      } else if (error_message.contains('already friends with this user')) {
        return "AlreadyFriends";
      }
      if (error_message.startsWith('el numero maximo de participantes')) {
        return "ParticipantsMinimumNotMet";
      } else if (error_message.startsWith('El usuario') &&
          error_message.contains('es el creador del evento (ya esta dentro)')) {
        return "CreatorCannotJoin";
      } else if (error_message.startsWith('El usuario') &&
          error_message.contains('ya esta dentro del evento')) {
        return "AlreadyParticipating";
      } else if (error_message.startsWith('El evento') &&
          error_message.contains('ya esta lleno!')) {
        return "EventFull";
      } else if (error_message.startsWith('El evento') &&
          error_message.contains('ya ha acabado!')) {
        return "EventEnded";
      } else if (error_message.startsWith('el usuario') &&
          error_message.contains('se han unido CON EXITO')) {
        return "JoinSuccess";
      } else if (error_message.startsWith('El usuario') &&
          error_message.contains('no es participante del evento')) {
        return "NotAParticipant";
      } else if (error_message.startsWith('El usuario') &&
          error_message
              .contains('es el creador del evento (no puede abandonar)')) {
        return "CreatorCannotLeave";
      } else if (error_message.startsWith('el participante') &&
          error_message.contains('ha abandonado CON EXITO')) {
        return "LeaveSuccess";
      } else if (error_message
              .startsWith('el numero maximo de participantes ') &&
          error_message.contains(' ha de ser mas grande que 2')) {
        return "ParticipantsMinimumNotMet";
      }
    }
    switch (error_message) {
      case "la imagen del evento no es una URL valida":
        return "InvalidImageUrl";

      case "A user cannot join a event for others":
        return "UnauthorizedEventJoin";

      case "A user cannot leave a event for others":
        return "UnauthorizedEventLeave";

      case "Error en el query de participante":
        return "ParticipantQueryError";

      case "the id of the event isn't in the URL as a query parameter with name eventid :(":
        return "EventIdMissing";

      case "the id of the user isn't in the URL as a query parameter with name userid :(":
        return "UserIdMissing";

      case "This email is banned":
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BannedUserPage()),
          );
        });
        return "EmailBanned";

      case "Error loading args":
        return "ArgsLoadingError";

      case "Error getting the event":
        return "EventQueryError";

      case "Error when querying participants":
        return "ParticipantsQueryError";

      case "A user cannot see the events that another user participated in":
        return "UnauthorizedEventAccess";

      case "Unexpected error when passing events to JSON format":
        return "JsonConversionError";

      case "The JSON body from the request is poorly defined":
        return "InvalidJsonBody";

      case "A user cannot delete events if they are not the creator":
        return "UnauthorizedEventDeletion";

      case "error while querying participants of an event":
        return "EventParticipantsQueryError";

      case "error while deleting participants of an event":
        return "EventParticipantsDeletionError";

      case "error while querying likes of an event":
        return "EventLikesQueryError";

      case "error while deleting likes of an event":
        return "EventLikesDeletionError";

      case "error while deleting reviews of an event":
        return "EventReviewsDeletionError";

      case "error while deleting the event":
        return "EventDeletionError";

      case "Event creator not found":
        return "EventCreatorNotFound";

      case "An unexpected error ocurred":
        return "UnexpectedError";

      case "Error when querying events":
        return "EventsQueryError";

      case "The name is not defined!":
        return "MissingEventName";

      case "The start date must be greater than the end date":
        return "InvalidDateRange";

      case "The start date and the end date are the same":
        return "IdenticalDates";

      case "Date_started is before the now time":
        return "PastStartDate";

      case "date_started or date_ended aren't real dates or they don't exist!":
        return "InvalidDateFormat";

      case "Any event match with the filter":
        return "NoMatchingEvents";

      case "Error while querying events":
        return "RecentEventsQueryError";

      case "Successful DELETE":
        return "DeleteSuccess";

      case "Mira el JSON body de la request, hay un atributo mal definido":
        return "InvalidJsonBody";

      case "A user can't like for others":
        return "UnauthorizedLikeAction";

      case "El usuario ya ha dado like a este evento":
        return "DuplicateLikeError";

      case "Error nuevo de base de datos, ¿cual es?":
        return "UnknownDatabaseError";

      case "A user can't remove likes for others":
        return "UnauthorizedDislikeAction";

      case "The like of user {delete_user_id} in event {delete_event_id} doesn't exist":
        return "LikeNotFound";

      case "A user can't get the likes of the events of someone else":
        return "UnauthorizedLikesAccess";

      case "Unexpected error":
        return "UnknownError";

      case "add_paymentthe id of the event isn't in the URL as a query parameter with name eventid :(":
        return "Event ID is missing in request";

      case "event_id isn't a valid UUID":
        return "Invalid Event ID format";

      case String s when s.contains("doesn't exist"):
        return "Event not found";

      case String s when s.contains("is the creator of the event"):
        return "Event creator cannot make payments";

      case "the amount of the payment isn't in the URL as a query parameter with name eventid :(":
        return "Payment amount is missing";

      case "Amount paid is not the same as the event amount":
        return "Payment amount doesn't match event amount";

      case "the type of the payment isn't in the URL as a query parameter with name eventid :(":
        return "Payment type is missing";

      case "the id of the payment isn't in the URL as a query parameter with name eventid :(":
        return "Payment ID is missing";

      case String s when s.contains("already paid for this event"):
        return "User already paid for this event";

      case "Integrity error, FK violated (algo no esta definido en la BD) o ya existe la payment en la DB":
        return "Database integrity error";

      case "Successful verification":
        return "SuccessfulVerificationContent";

      case "User already verified":
        return "UserAlreadyVerified";

      case "Event doesn't exist":
        return "EventNotExist";

      case "You are not the creator of this event":
        return "NotCreatorScaning";

      case "Code is not in the url":
        return "CodeNotinUrl";

      case "User or Code is not correct for this event":
        return "IncorrentCode";

      case "parent_post_id is invalid":
        return "InvalidParentPostId";

      case "text isn't is invalid":
        return "InvalidPostText";

      case "post_image_uris isn't is invalid":
        return "InvalidPostImages";

      case "Error de DB nuevo, cual es?":
        return "UnknownDatabaseError";

      case "User_id isn't a valid UUID":
        return "InvalidUserIdFormat";

      case "Post {post_id} doesn't exist":
        return "PostNotFound";

      case "Error while querying Like":
        return "LikeQueryError";

      case "You are not participant of this event":
        return "NotEventParticipant";

      case "Event is already banned":
        return "EventAlreadyBanned";

      case "comment is not in the body":
        return "MissingComment";

      case "Amount paid is not the same":
        return "PaymentAmountMismatch";

      case "Un usuario no puede crear un evento por otra persona":
        return "UnauthorizedEventCreation";

      case "Error creating event's chat":
        return "EventChatCreationError";

      case "User FK violated, el usuario user_creator no esta definido en la BD":
        return "InvalidEventCreator";

      case "FK violated":
        return "ForeignKeyViolation";

      case "la id no es una UUID valida":
        return "InvalidUuidFormat";

      case "El evento {event_id} ha dado un error al hacer query":
        return "EventQueryError";

      case "El evento {event_id} no existe":
        return "EventNotFound";

      case "solo el usuario creador puede modificar su evento":
        return "UnauthorizedEventModification";

      case "A user cannot update the events of others":
        return "UnauthorizedEventUpdate";

      case "Error de DB al eliminar imágenes antiguas":
        return "EventImageDeletionError";

      case "evento modificado CON EXITO":
        return "EventUpdateSuccess";

      case "atributo name no esta en el body o es null":
        return "MissingEventName";

      case "atributo description no esta en el body o es null":
        return "MissingDescription";

      case "atributo date_started no esta en la URL o es null":
        return "MissingStartDate";

      case "atributo date_end no esta en la URL o es null":
        return "MissingEndDate";

      case "atributo user_creator no esta en la URL o es null":
        return "MissingCreatorId";

      case "atributo longitud no esta en la URL o es null":
        return "MissingLongitude";

      case "atributo latitud no esta en la URL o es null":
        return "MissingLatitude";

      case "atributo max_participants no esta en la URL o es null":
        return "MissingMaxParticipants";

      case "atributo event_image_uris no esta en la URL o es null":
        return "MissingEventImages";

      case "The name attribute is vulgar":
        return "ProfaneName";

      case "The description attribute is vulgar":
        return "ProfaneDescription";

      case "name isn't a string!":
        return "InvalidNameFormat";

      case "description isn't a string!":
        return "InvalidDescriptionFormat";

      case "name, description or user_creator is empty!":
        return "EmptyRequiredFields";

      case "Description es demasiado largo":
        return "DescriptionTooLong";

      case "Name es demasiado largo":
        return "NameTooLong";

      case "max participants no es un mumero":
        return "InvalidMaxParticipantsFormat";

      case "No user found for this email":
        return "UserNotFoundByEmail";

      case "Can't add yourself as your friend, but you do have high self-esteem.":
        return "CannotAddSelfAsFriend";

      case "Must indicate an email":
        return "EmailRequired";

      case "Missing json object":
        return "MissingJson";

      case "Email attribute missing in json":
        return "EmailMissingInJson";

      case "Password attribute missing in json":
        return "PasswordMissingInJson";

      case "Verification code attribute missing in json":
        return "VerificationCodeMissing";

      case "Missing argument 'id'":
        return "MissingUserId";

      case "Missing argument 'res'":
        return "MissingResponse";

      case "Verification code was never sent to this email or the code has expired.":
        return "VerificationCodeInvalidOrExpired";

      case "Verification code does not coincide with code sent to email":
        return "VerificationCodeMismatch";

      case "Code does not exist or it has expired":
        return "InvalidOrExpiredCode";

      case "Invitation has expired":
        return "InvitationExpired";

      case "No invitation found":
        return "NoInvitationFound";

      case "You have already been invited by this user":
        return "AlreadyInvited";

      case "Invitation was rejected":
        return "InvitationRejected";

      case "Invitation is pending":
        return "InvitationPending";

      case "Invitation has already been accepted":
        return "InvitationAlreadyAccepted";

      case "El chat solicitado no existe":
        return "ChatNotFound";

      case "Private chat.":
        return "PrivateChatError";

      case "You are not the creator of the chat.":
        return "NotChatCreator";

      case "No such chat.":
        return "ChatNotFound";

      case "No hay ningun chat con esas credenciales":
        return "InvalidChatCredentials";

      case "El usuario no es miembro del chat":
        return "NotChatMember";

      case "El chat no tiene mienbros":
        return "ChatHasNoMembers";

      case "El mensaje solicitado no existe":
        return "MessageNotFound";

      case "El usuario no es el creador del mensaje":
        return "NotMessageSender";

      case "Falla el eliminar el message indicado":
        return "MessageDeletionFailed";

      case "The JSON argument is bad defined":
        return "InvalidJsonFormat";

      case "Chat Id is not defined or its value is null":
        return "MissingChatId";

      case "New member Id is not defined or its value is null":
        return "MissingMemberId";

      case "Message Id is not defined or its value is null":
        return "MissingMessageId";

      case "Text is not defined or its value is null":
        return "MissingText";

      case "The text is not a string":
        return "InvalidTextFormat";

      case "The user id isn't a valid uuid":
        return "InvalidUserIdFormat";

      case "The chat id not is a valid uuid":
        return "InvalidChatIdFormat";

      case "FK problems, the user or the event doesn't exists":
        return "ForeignKeyViolation";

      case "Something happened in the insert":
        return "DatabaseInsertError";

      case "Falla el eliminar los chats":
        return "ChatDeletionError";

      case "Error cuando buscando los memienbros":
        return "MemberQueryError";

      case "Error cuando buscando chat":
        return "ChatQueryError";

      case "Error cuando buscando los mensajes":
        return "MessageQueryError";

      case "Error cuando buscando el link del imagen del chat":
        return "ChatImageQueryError";

      case "No such user.":
        return "UserNotFound";

      case "The user has no chats":
        return "UserHasNoChats";

      case "Missing credentials in json body.":
        return "MissingCredentials";

      case "Email or password are wrong.":
        return "InvalidCredentials";

      case "Only administrators can access this resource.":
        return "AdminOnly";

      case "Only administrators can make this action.":
        return "AdminOnly";

      case "Authentication method not available for this email.":
        return "AuthMethodNotAvailable";

      case "An administrator user cannot be banned by another administrator user, please contact a higher clearence member.":
        return "CannotBanAdmin";

      case "User email already banned.":
        return "UserAlreadyBanned";

      case "This email is not in the banned emails list.":
        return "UserNotBanned";

      case "No such event.":
        return "EventNotFound";

      case "Event already banned.":
        return "EventAlreadyBanned";

      case "This event is not in the banned events list.":
        return "EventNotBanned";

      case "Missing id in json body.":
        return "MissingId";

      case "id isn't a valid UUID":
        return "InvalidUUID";

      case "Missing email in json body.":
        return "MissingEmail";

      case "Missing event_id in json body.":
        return "MissingEventId";
      case String s
          when s.contains("Integrity error") || s.contains("Error de DB nuevo"):
        return "DatabaseOperationFailed";

      case String s when s.contains("isn't a valid UUID"):
        return s.contains("event") || s.contains("eventid")
            ? "InvalidEventId"
            : s.contains("user") || s.contains("userid")
                ? "InvalidUserId"
                : "InvalidUuidFormat";

      case String s when s.contains("doesn't exist"):
        return s.contains("Event")
            ? "EventNotFound"
            : s.contains("User")
                ? "UserNotFound"
                : s.contains("Post")
                    ? "PostNotFound"
                    : "ResourceNotFound";
      // Default case - show the complete server message
      default:
        return data['error_message'] ?? 'An error occurred';
    }
  }
}
