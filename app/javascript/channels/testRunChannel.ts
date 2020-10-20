import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { Submission } from '../components/student/Editor'
import { TestRun } from '../components/student/editor/TestRunSummary'
import { typecheck } from '../utils/typecheck'

export class TestRunChannel {
  subscription: ActionCable.Channel

  constructor(submission: Submission, received: (testRun: TestRun) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'Submission::TestRunsChannel',
        submission_uuid: submission.uuid,
      },
      {
        received: (response: any) => {
          const formattedResponse = camelizeKeys(response)

          received(typecheck<TestRun>(formattedResponse, 'testRun'))
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
