# frozen_string_literal: true
module PipelineStep
  class HeartModelCalculation
    def self.run(patient, user)
      validate_procedure_status!(patient)
      computation = RimrockComputation.create(
        patient: patient,
        user: user,
        pipeline_step: 'after_parameter_estimation',
        script: ScriptGenerator::HeartModel.new(patient, user).call
      )
      Rimrock::StartJob.perform_later computation
      computation
    end

    private_class_method

    def self.validate_procedure_status!(patient)
      statuses = Patient.procedure_statuses
      model_ready = statuses[patient.procedure_status] >= statuses['after_parameter_estimation']
      raise('Heart Model Computation can be run after parameter estimation') unless model_ready
    end
  end
end
