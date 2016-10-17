import Functional

// MARK: - Section

public struct FormSectionConfiguration: EmptyType {
	public let title: String?
	public init(title: String?) {
		self.title = title
	}

	public static var empty: FormSectionConfiguration {
		return FormSectionConfiguration(title: nil)
	}
}

public struct FormSectionModel: FormContainerType {
	public typealias ConfigurationType = FormSectionConfiguration
	public typealias Subtype = Field

	public let configuration: FormSectionConfiguration
	public let subelements: [Field]

	public init(configuration: FormSectionConfiguration, subelements: [Field]) {
		self.configuration = configuration
		self.subelements = subelements
	}

	public func getFieldIndexPath(for subelementIndex: UInt) -> FieldIndexPath {
		return FieldIndexPath.with(fieldIndex: subelementIndex)
	}
}

// MARK: - Step

public struct FormStepConfiguration: EmptyType {
	public let title: String?
	public init(title: String?) {
		self.title = title
	}

	public static var empty: FormStepConfiguration {
		return FormStepConfiguration(title: nil)
	}
}

public struct FormStepModel: FormContainerType {
	public typealias ConfigurationType = FormStepConfiguration
	public typealias Subtype = FormSectionModel

	public let configuration: FormStepConfiguration
	public let subelements: [FormSectionModel]

	public init(configuration: FormStepConfiguration, subelements: [FormSectionModel]) {
		self.configuration = configuration
		self.subelements = subelements
	}

	public func getFieldIndexPath(for subelementIndex: UInt) -> FieldIndexPath {
		return FieldIndexPath.with(sectionIndex: subelementIndex)
	}
}

// MARK: - Form

public struct FormConfiguration: EmptyType {
	public let title: String?
	public init(title: String?) {
		self.title = title
	}

	public static var empty: FormConfiguration {
		return FormConfiguration(title: nil)
	}
}

public struct FormModel: FormContainerType {
	public typealias ConfigurationType = FormStepConfiguration
	public typealias Subtype = FormStepModel

	public let configuration: FormStepConfiguration
	public let subelements: [FormStepModel]

	public init(configuration: FormStepConfiguration, subelements: [FormStepModel]) {
		self.configuration = configuration
		self.subelements = subelements
	}

	public func getFieldIndexPath(for subelementIndex: UInt) -> FieldIndexPath {
		return FieldIndexPath.with(stepIndex: subelementIndex)
	}
}