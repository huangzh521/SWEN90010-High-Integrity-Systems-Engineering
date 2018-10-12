// ===========================================================================
// SWEN90010 2018 - Assignment 3 Submission
// by <PUT YOUR NAMES HERE>
// ===========================================================================

module icd
open util/ordering[State] as ord

// =========================== System State ==================================
// a type for storing amounts of Joules
sig Joules {}

// the initial number of joules to deliver (30)
one sig InitialJoulesToDeliver extends Joules {}

// we ignore the clinical assistants for simplicity in this model 
abstract sig Role {}
one sig Cardiologist, Patient extends Role {}

// principals have associated roles
sig Principal {
  roles : set Role
}

// an abstract signature for network messages
abstract sig Message {
  source : Principal
}

// ChangeSettingsRequest messages
// Note: we ignore the tachybound part to keep things tractable
sig ChangeSettingsMessage extends Message {
  joules_to_deliver : Joules
}

// ModeOn message
sig ModeOnMessage extends Message {
}


// Modes: either On or Off
abstract sig Mode {}
one sig ModeOn, ModeOff extends Mode {}

// meta information in the model that identifies the last action performed
abstract sig Action {
  who : Principal  // indentifies which principal caused the action
}

sig SendModeOn, RecvModeOn,
    SendChangeSettings, RecvChangeSettings
    extends Action {}

// represents the occurrence of attacker actions
one sig AttackerAction extends Action {}

// a dummy action which will be the "last action" in the initial state
// we do this just to make sure that every state has a last action
one sig DummyInitialAction extends Action {}

// The system state
sig State {
  network : lone Message,              // CAN Bus state: holds up to one message
  icd_mode : Mode,                 // whether IXS system is in on or off mode
  impulse_mode : Mode,             // whether the impulse generator is on or off
  joules_to_deliver : Joules,      // joules to deliver for ventrical fibrillation
  authorised_card : Principal,     // the authorised cardiologist
  last_action : Action,            // identifies the most recent action performed
}

// an axiom that restricts the model to never allow more than one messasge on
// the network at a time; a simplifying assumption to ease the analysis
fact {
  all s : State | lone s.network
}

// =========================== Initial State =================================

// The initial state of the system:
//   - empty network, 
//   - ICD and impulse generator both off
//   - joules to deliver at initial value
//   - the authorised cardiologist is really a cardiologist
//   - last_action set to the dummy value
pred Init[s : State] {
  no s.network and s.icd_mode = ModeOff and s.impulse_mode = ModeOff 
  and s.joules_to_deliver = InitialJoulesToDeliver and 
  Cardiologist in s.authorised_card.roles and
  s.last_action = DummyInitialAction
}

// =========================== Actions =======================================

// Models the action in which a ModeOn message is sent on the network by the
// authorised cardiologist.
// Precondition: none
// Postcondition: network now contains a ModeOn message from the authorised 
//                          cardiologist
//                          last_action is SendModeOn for the message's sender
//                          and nothing else changes
pred send_mode_on[s, s' : State] {
  some m : ModeOnMessage | m.source = s.authorised_card and
  s'.network = s.network + m and
  s'.icd_mode = s.icd_mode and
  s'.impulse_mode = s.impulse_mode and
  s'.joules_to_deliver = s.joules_to_deliver and
  s'.authorised_card = s.authorised_card and
  s'.last_action in SendModeOn and
  s'.last_action.who = m.source
}

// Models the action in which a valid ModeOn message is received by the
// ICD from the authorised cardiologist, causing the ICD system's mode to change 
// from Off to On and the message to be removed from the network
// Precondition: <FILL IN HERE>
//                         ICD system is in ModeOff
//                         impulse generator is in ModeOff
//                         network now contains a ModeOnMessage from the authorised cardiologist    
// Postcondition: <FILL IN HERE>
//                          ICD system is in ModeOn
//                          impulse generator is in ModeOn
//                          ModeOnMessage is removed from the network
//                          last_action in RecvModeOn and 
//                          last_action.who = the source of the ModeOn message
//                          and nothing else changes
pred recv_mode_on[s, s' : State] {
  // <FILL IN HERE>
  s.icd_mode = ModeOff and
  s.impulse_mode = ModeOff and
  one s.network and
  s.network in ModeOnMessage and
  s.network.source = s.authorised_card and
  
  s'.icd_mode = ModeOn and
  s'.impulse_mode = ModeOn and
  no s'.network and
  s'.joules_to_deliver = s.joules_to_deliver and
  s'.authorised_card = s.authorised_card and
  s'.last_action in RecvModeOn and
  s'.last_action.who = s.network.source
}

// Models the action in which a valid ChangeSettingsRequest message is sent
// on the network, from the authorised cardiologist, specifying the new quantity of 
// joules to deliver for ventrical fibrillation.
// Precondition: <FILL IN HERE> none
// Postcondition: <FILL IN HERE>
//                           network now contains a ChangeSettingsMessage from the authorised cardiologist
//                           last_action in SendChangeSettings and
//                           last_action.who = the source of the ChangeSettingsMessage
//                           and nothing else changes
pred send_change_settings[s, s' : State] {
  // <FILL IN HERE>
  one m : ChangeSettingsMessage | m.source = s.authorised_card and
  s'.network = s.network + m and
  s'.icd_mode = s.icd_mode and
  s'.impulse_mode = s.impulse_mode and
  s'.joules_to_deliver = s.joules_to_deliver and
  s'.authorised_card = s.authorised_card and
  s'.last_action in SendChangeSettings and
  s'.last_action.who = m.source
}

// Models the action in which a valid ChangeSettingsRequest message is received
// by the ICD, from the authorised cardiologist, causing the current joules to be 
// updated to that contained in the message and the message to be removed from the 
// network.
// Precondition: <FILL IN HERE>
//                         ICD system is in ModeOff
//                         impulse generator is in ModeOff
//                         network now contains a ChangeSettingsMessage from the authorised cardiologist   
// Postcondition: <FILL IN HERE>
//                           the current joules is updated to joules_to_deliver contained in the message
//                           ChangeSettingsMessage is removed from the network
//                           last_action in RecvChangeSettings and
//                           last_action.who = the source of the ChangeSettingsMessage
//                           and nothing else changes
pred recv_change_settings[s, s' : State] {
  // <FILL IN HERE>
  s.icd_mode = ModeOff and
  s.impulse_mode = ModeOff and
  one s.network and
  s.network in ChangeSettingsMessage and
  s.network.source = s.authorised_card and
 
  s'.joules_to_deliver = s.network.joules_to_deliver and
  no s'.network and
  s'.icd_mode = s.icd_mode and
  s'.impulse_mode = s.impulse_mode and
  s'.authorised_card = s.authorised_card and
  s'.last_action in RecvChangeSettings and
  s'.last_action.who = s.network.source
}

// =========================== Attacker Actions ==============================

// Models the actions of a potential attacker that has access to the network
// The only part of the system state that the attacker can possibly change
// is that of the network
//
// NOTE: In the initial template you are given, the attacker
// is modelled as being able to modify the network contents arbitrarily.
// Howeever, for later parts of the assignment you will change this definition
// to only permit certain kinds of modifications to the state of the network.
// When doing so, ensure you update the following line that describes the
// attacker's abilities.
//
// Attacker's abilities: can modify network contents arbitrarily
//                       <UPDATE HERE>
//
// Precondition: none
// Postcondition: network state changes in accordance with attacker's abilities
//                last_action is AttackerAction
//                and nothing else changes
pred attacker_action[s, s' : State] {
  some m : Message | m.source not in s.authorised_card and
  (s'.network = m or no s'.network or s'.network = s.network) and

  s'.icd_mode = s.icd_mode and
  s'.joules_to_deliver = s.joules_to_deliver and
  s'.impulse_mode = s.impulse_mode and
  s'.authorised_card = s.authorised_card and
  s'.last_action = AttackerAction

}


// =========================== State Transitions and Traces ==================

// State transitions occur via the various actions of the system above
// including those of the attacker.
pred state_transition[s, s' : State] {
  send_mode_on[s,s']
  or recv_mode_on[s,s']
  or send_change_settings[s,s']
  or recv_change_settings[s,s']
  or attacker_action[s,s']
}

// Define the linear ordering on states to be that generated by the
// state transitions above, defining execution traces to be sequences
// of states in which each state follows in the sequence from the last
// by a state transition.
fact state_transition_ord {
  all s: State, s': ord/next[s] {
    state_transition[s,s'] and s' != s
  }
}

// The initial state is first in the order, i.e. all execution traces
// that we model begin in the initial state described by the Init predicate
fact init_state {
  all s: ord/first {
    Init[s]
  }
}

// =========================== Properties ====================================


// An example assertion and check:
// Specifies that once the ICD is in the On mode, it never leaves
// the On mode in all future states in the execution trace, 
// i.e. it stays in the On mode forever.
assert icd_never_off_after_on {
  all s : State | all s' : ord/nexts[s] | 
     s.icd_mode = ModeOn implies s'.icd_mode = ModeOn
}

check icd_never_off_after_on for 30 expect 0



// Describes a basic sanity condition of the system about how the modes of the
// ICD system and the impulse generator are related to each other. 
// This condition should be true in all states of the system, 
// i.e. it should be an "invariant"
pred inv[s : State] { 
  // <FILL IN HERE>
  s.icd_mode = ModeOn implies s.impulse_mode = ModeOn else s.impulse_mode = ModeOff
}

// Specifies that the invariant "inv" above should be true in all states
// of all execution traces of the system
assert inv_always {
  inv[ord/first] and all s : ord/nexts[ord/first] | inv[s]
  // NOTE (as a curiosity): the above is equivalent to saying
  // all s : State | inv[s]
  // This is because when checking this assertion, the linear order
  // defined on States causes all States considered by Alloy to come
  // from the linear order
}

// Check that the invariant is never violated during 15
// state transitions
check inv_always for 5
// <FILL IN HERE: does the assertion hold? why / why not?>
// NOTE: you will want to use smaller thresholds if getting
//       counterexamples, so you can interpret them
// This assertion holds in here. Because at the initial state, both ICD system and impulse generator 
// are in ModeOff. Once the mode on message can be received,
// the mode of both ICD system and impulse generator will change from off
// to on together in the recv_change_settings predicate. 
// Even if attacker can impersonate the authorised cardiologist
// then inject the mode on message onto the network and the message is received, 
// ICD system and impulse generator will still change to ModeOn together.
// Under the updated attaker model, the mode on message sent from the attacker will not be received.
// So the modes of ICD system and impulse generator will always stay the same.


// An unexplained assertion. You need to describe the meaning of this assertion
// in the comment <FILL IN HERE>
// This assertion means that for all the states, if the last action is not an AttackerAction, 
// then if it is RecvChangeSettings action, the role of sending ChangeSettingsMessage 
// should not be a patient.
// That is, this assertion checks that the ICD system should not receive the ChangeSettingsMessage 
// if the message is sent from the authorised patient who is not an attacker.
// This assertion is based on R2.5 in Assignment 1 specification:
// An authorised Cardiologist can increase or decrease the number of joules delivered for
// a ventricle fibrillation when system is in the Off mode.
assert unexplained_assertion {
  all s : State | (all s' : State | s'.last_action not in AttackerAction) =>
      s.last_action in RecvChangeSettings =>
      Patient not in s.last_action.who.roles
}

check unexplained_assertion for 5
// <FILL IN HERE: does the assertion hold? why / why not?>
// This assertion does not hold in this program. 
// Before updating the attacker model, in the counterexample of this check, 
// the principle has two types of roles, that are cardiogogist and patient.
// The intial state only requires Cardiologist role included in the authorised_card principle, 
// but this principle also can include the Patient role.
// Therefore, the message which has the source from authorised_card can be sent from both authorised
// cardiologist and patient, then cause this check failed.
// After updating the attacker model, even if the attacker cannot impersonate the authorsised principle,
// this check still fail to hold. Because recv_change_settings predicate
// does not require the message should only be source from Cardiologist role, an authorised Patient role
// still can sent ChangeSettingsMessage and received by the system.

// Check that the device turns on only after properly instructed to
// i.e. that the RecvModeOn action occurs only after a SendModeOn action has occurred
assert turns_on_safe {
  // <FILL IN HERE>
  all s : State | all s' : ord/next[s] | 
     s'.last_action in RecvModeOn implies s.last_action in SendModeOn 
     //(s.last_action in SendChangeSettings implies s'.last_action = RecvChangeSettings) 

}

// NOTE: you may want to adjust these thresholds for your own use
check turns_on_safe for 5 but 8 State
// <FILL IN HERE: does the assertion hold in the updated attacker model in which
// the attacker cannot guess Principal ids? why / why not?>
// what additional restrictions need to be added to the attacker model?

// Attacks still permitted by the updated attacker model:
// 
// <FILL IN HERE>


// Relationship to our HAZOP study:
//
// <FILL IN HERE>
