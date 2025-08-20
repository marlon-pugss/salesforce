@IsTest
public class TestActions {
    
    public class Assert implements Action {
        private Boolean condition;
        private String message;

        public Assert(Boolean condition, String message) {
            this.condition = condition;
            this.message = message;
        }

        public void run() {
            System.assert(condition, message);
        }
    }

    public class DoNothing implements Action {
        public void run() { }
    }

    public class Listener implements Action {
        public Boolean called { get; private set; }
        public Listener() { this.called = false; }
        public void run() { this.called = true; }
    }

}