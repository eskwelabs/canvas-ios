/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import CourseActions from '../courses/actions'
import type { AssignmentListState } from './map-state-to-props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList, updateAssignment } = Actions
const { refreshGradingPeriods } = CourseActions

export const assignmentGroups: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID, gradingPeriodID }) => {
      if (gradingPeriodID != null) return state

      let entities = state.assignmentGroupEntities || {}
      result.data.forEach((entity) => {
        entities[entity.id] = entity
      })

      return {
        ...state,
        ...entities,
      }
    },
  }),
}, defaultState)

export const assignments: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      let entities = { ...state.assignments }
      result.data.forEach((entity) => {
        entity.assignments.forEach(assignment => {
          entities[assignment.id] = { assignment }
        })
      })

      return {
        ...state,
        ...entities,
      }
    },
  }),
  [updateAssignment.toString()]: handleAsync({
    pending: (state, { updatedAssignment, originalAssignment }) => {
      let id = updatedAssignment.id
      let entity = { ...state[id] }
      entity.assignment = updatedAssignment
      entity.pending = (entity.pending || 0) + 1
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
    resolved: (state, { updatedAssignment, originalAssignment }) => {
      let id = updatedAssignment.id
      let entity = { ...state[id] }
      entity.pending--
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
    rejected: (state, { updatedAssignment, originalAssignment, error }) => {
      let id = originalAssignment.id
      let entity = { ...state[id] }
      entity.assignment = originalAssignment
      entity.pending = (entity.pending || 0) - 1
      entity.error = error
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
  }),
}, defaultState)

export let refDefaultState: AssignmentGroupsRefState = { refs: [], pending: 0 }

export const assignmentGroupRefs: Reducer<AssignmentListState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, { result, courseID, gradingPeriodID }) => {
      let newState = {
        ...state,
        pending: state.pending - 1,
      }

      if (gradingPeriodID == null) {
        newState.refs = result.data.map((group) => group.id)
      }

      return newState
    },
    rejected: (state, response) => {
      let errorMessage = i18n('Could not get list of assignments')
      return {
        ...state,
        error: errorMessage,
        pending: state.pending - 1,
      }
    },
  }),
  [refreshGradingPeriods.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state) => ({ ...state, pending: state.pending - 1 }),
    rejected: (state) => ({ ...state, pending: state.pending - 1 }),
  }),
}, refDefaultState)
