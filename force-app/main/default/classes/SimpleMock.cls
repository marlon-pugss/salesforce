@IsTest
public class SimpleMock implements System.StubProvider { 

    private Map<String, Answer> answers = new Map<String, Answer>();
    private Map<String, Verification> verifications = new Map<String, Verification>();
    private List<Object> arguments = new List<Object>();

    public Object handleMethodCall(
            Object mockedObject,
            String methodName,
            Type returnType,
            Type[] paramTypes,
            String[] paramNames,
            Object[] args) {

        String normalizedMethodName = methodName.toLowerCase();

        if (!answers.containsKey(normalizedMethodName)) 
            throw new MethodNotConfiguredException(methodName);

        if (!verifications.containsKey(normalizedMethodName)) {
            verifications.put(normalizedMethodName, new Verification(this, methodName));
        }

        verifications.get(normalizedMethodName).handleMethodCall(paramTypes, args);

        arguments.addAll(args);

        Answer answer = answers.get(normalizedMethodName);

        switch on (answer.behavior) {
            when RETURN_VALUE {
                return answer.mockedValue;
            } 
            when EXECUTE_CODE {
                ((Action) answer.mockedValue).run();
                return null;
            }
            when THROW_EXCEPTION {
                throw (Exception) answer.mockedValue;
            }
            when else {
                throw new UnsupportedAnswerBehaviorException(answer.behavior);
            }
        }
    }

    public Object forType(Type classToMock) {
        return Test.createStub(classToMock, this);
    }

    public Answer when(String methodName) {
        Answer answer = new Answer(this);
        registerAnswer(methodName, answer);
        return answer;
    }

    public Verification verify(String methodName) {
        String normalizedMethodName = methodName.toLowerCase();
        if (!verifications.containsKey(normalizedMethodName)) {
            verifications.put(normalizedMethodName, new Verification(this, methodName));
        }

        return verifications.get(normalizedMethodName);
    }

    public List<Object> getArguments() {
        return arguments;
    }

    private void registerAnswer(String methodName, Answer answer) {
        answers.put(methodName.toLowerCase(), answer);
    }

    public class Answer {
        private SimpleMock mock { get; set; }
        public Behavior behavior { get; private set; }
        public Object mockedValue { get; private set; }

        public Answer(SimpleMock mock) {
            this.mock = mock;
        }

        public SimpleMock thenReturn(Object returnValue) {
            return thenAnswer(SimpleMock.Behavior.RETURN_VALUE, returnValue);
        }

        public SimpleMock thenThrow(Exception ex) {
            return thenAnswer(SimpleMock.Behavior.THROW_EXCEPTION, ex);
        }

        public SimpleMock thenRun(Action action) {
            return thenAnswer(SimpleMock.Behavior.EXECUTE_CODE, action);
        }

        public SimpleMock thenAssert(Boolean condition, String message) {
            return thenRun(new TestActions.Assert(condition, message));
        }

        public SimpleMock thenDoNothing() {
            return thenRun(new TestActions.DoNothing());
        }

        private SimpleMock thenAnswer(Behavior behavior, Object mockedValue) {
            this.behavior = behavior;
            this.mockedValue = mockedValue;
            return mock;
        }
    }

    public class Verification {

        private SimpleMock mockInstance;
        private String methodName;
        private MethodCall[] methodCalls;

        private Verification(SimpleMock mockInstance, String methodName) {
            this.mockInstance = mockInstance;
            this.methodName = methodName;
            this.methodCalls = new MethodCall[]{};
        }

        private void handleMethodCall(Type[] paramTypes, Object[] params) {
            methodCalls.add(new MethodCall(paramTypes, params));
        }

        public SimpleMock notCalled() {
            return calledTimes(0);
        }

        public SimpleMock calledOnce() { 
            return calledTimes(1);
        }

        public SimpleMock calledTwice() {
            return calledTimes(2);
        }

        public SimpleMock calledTimes(Integer expectedTimes) {
            if (methodCalls.size() != expectedTimes) {
                String message = 'Expected method "{0}" to be called {1} time(s), but it was called {2} time(s)';
                throw new VerificationFailedException(String.format(message, new Object[] { methodName, expectedTimes, methodCalls.size() }));
            }
            return mockInstance;
        }

        public SimpleMock calledWith(Object param) {
            return calledWith(new Object[] { param });
        }

        public SimpleMock calledWith(Object param1, Object param2) {
            return calledWith(new Object[] { param1, param2 });
        }

        public SimpleMock calledWith(Object param1, Object param2, Object param3) {
            return calledWith(new Object[] { param1, param2, param3 });
        }

        public SimpleMock calledWith(Object[] params) {
            Mock.Matcher[] matchers = new Mock.Matcher[]{};

            for (Object param : params) {
                if (!(param instanceof Mock.Matcher)) {
                    matchers.add(Mock.value(param));
                } else {
                    matchers.add((Mock.Matcher) param);
                }
            }

            return calledWith(matchers);
        }

        public SimpleMock calledWith(Mock.Matcher[] matchers) {
            for (MethodCall call : methodCalls) {
                if (calledWith(call, matchers)) {
                    return mockInstance;
                }
            }

            String message = 'Expected method "{0}" to be called with {1}, but it was called with {2}';
            throw new VerificationFailedException(String.format(message, new Object[] { methodname, matchers, methodCalls }));
        }

        private Boolean calledWith(MethodCall call, Mock.Matcher[] matchers) {
            Type[] calledParamTypes = call.getParamTypes();
            Object[] calledParams = call.getParams();

            if (calledParams.size() != matchers.size()) return false;

            for (Integer i = 0; i < matchers.size(); i++) {
                Mock.Matcher matcher = matchers.get(i);
                Object calledParam = calledParams.get(i);
                Type calledParamType = calledParamTypes.get(i);

                if (matcher instanceof Mock.TypeMatcher) {
                    if (!matcher.matches(calledParamType)) return false;
                } else if (matcher instanceof Mock.ValueMatcher) {
                    if (!matcher.matches(calledParam)) return false;
                } else {
                    throw new IllegalArgumentException('Unsupported matcher: ' + matcher);
                }
            }

            return true;
        }
    }

    private class MethodCall {
        private Type[] paramTypes;
        private Object[] params;

        private MethodCall(Type[] paramTypes, Object[] params) {
            this.paramTypes = paramTypes;
            this.params = params;
        }

        private Type[] getParamTypes() { return paramTypes; }
        private Object[] getParams() { return params; }
    }

    private enum Behavior { 
        RETURN_VALUE, 
        EXECUTE_CODE, 
        THROW_EXCEPTION 
    }

    public class MethodNotConfiguredException extends Exception { 
        public MethodNotConfiguredException(String methodName, Object[] args) {
            this('The method ' + methodName + ' was called but its behavior is not configured for this mock. ' +
                  'Args: ' + String.valueOf(args));
        }
    }

    public class UnsupportedAnswerBehaviorException extends Exception {
        public UnsupportedAnswerBehaviorException(Behavior behavior) {
            this('The provided answer behavior is not supported: ' + behavior.name());
        }
    }

    public class VerificationFailedException extends Exception { }
}